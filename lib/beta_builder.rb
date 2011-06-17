require 'rake/tasklib'
require 'ostruct'
require 'fileutils'
require 'cfpropertylist'
require 'beta_builder/archived_build'
require 'beta_builder/deployment_strategies'

module BetaBuilder
  class Tasks < ::Rake::TaskLib
    def initialize(namespace = :beta, &block)
      @configuration = Configuration.new(
        :configuration => "Adhoc",
        :build_dir => "build",
        :auto_archive => false,
        :archive_path  => File.expand_path("~/Library/Application Support/Developer/Shared/Archived Applications"),
        :xcodebuild_path => "xcodebuild",
        :project_file_path => nil
      )
      @namespace = namespace
      yield @configuration if block_given?
      define
    end
    
    def xcodebuild(*args)
      system("#{@configuration.xcodebuild_path} #{args.join(" ")}")
    end
    
    class Configuration < OpenStruct
      def build_arguments
        args = "-target '#{target}' -configuration '#{configuration}' -sdk iphoneos"
        args << " -project #{project_file_path}" if project_file_path
      end
      
      def app_name
        "#{target}.app"
      end
      
      def ipa_name
        "#{target}.ipa"
      end
      
      def built_app_path
        "#{build_dir}/#{configuration}-iphoneos/#{app_name}"
      end
      
      def built_app_dsym_path
        "#{built_app_path}.dSYM"
      end
      
      def dist_path
        File.join("pkg/dist")
      end
      
      def ipa_path
        File.join(dist_path, ipa_name)
      end
      
      def deploy_using(strategy_name, &block)
        if DeploymentStrategies.valid_strategy?(strategy_name.to_sym)
          self.deployment_strategy = DeploymentStrategies.build(strategy_name, self)
          self.deployment_strategy.configure(&block)
        else
          raise "Unknown deployment strategy '#{strategy_name}'."
        end
      end
    end
    
    private
    
    def define
      namespace(@namespace) do
        desc "Build the beta release of the app"
        task :build => :clean do
          xcodebuild @configuration.build_arguments, "build"
        end
        
        task :clean do
          xcodebuild @configuration.build_arguments, "clean"
        end
        
        desc "Package the beta release as an IPA file"
        task :package => :build do
          if @configuration.auto_archive
            Rake::Task['beta:archive'].invoke
          end
                    
          FileUtils.rm_rf('pkg') && FileUtils.mkdir_p('pkg')
          FileUtils.mkdir_p("pkg/Payload")
          FileUtils.mv(@configuration.built_app_path, "pkg/Payload/#{@configuration.app_name}")
          Dir.chdir("pkg") do
            system("zip -r '#{@configuration.ipa_name}' Payload")
          end
          FileUtils.mkdir('pkg/dist')
          FileUtils.mv("pkg/#{@configuration.ipa_name}", "pkg/dist")
        end
        
        if @configuration.deployment_strategy
          desc "Prepare your app for deployment"
          task :prepare => :package do
            @configuration.deployment_strategy.prepare
          end
          
          desc "Deploy the beta using your chosen deployment strategy"
          task :deploy => :prepare do
            @configuration.deployment_strategy.deploy
          end
          
          desc "Deploy the last build"
          task :redeploy do
            @configuration.deployment_strategy.prepare
            @configuration.deployment_strategy.deploy
          end
        end
        
        desc "Build and archive the app"
        task :archive => :build do
          archive = BetaBuilder::ArchivedBuild.new(@configuration)
          archive.save_to(@configuration.archive_path)
        end
      end
    end
  end
end
