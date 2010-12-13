require 'rake/tasklib'
require 'ostruct'
require 'fileutils'
require 'cfpropertylist'
require 'beta_builder/archived_build'
require 'beta_builder/deployment_strategies/web'

module BetaBuilder
  class Tasks < ::Rake::TaskLib
    def initialize(&block)
      @configuration = Configuration.new(
        :configuration => "Adhoc",
        :build_dir => "build",
        :auto_archive => false,
        :archive_path  => File.expand_path("~/Library/MobileDevice/Archived Applications/")
      )
      @deployment_strategy = DeploymentStrategies::Web.new(@configuration)
      yield @configuration if block_given?
      define
    end
    
    class Configuration < OpenStruct
      def build_arguments
        "-target #{target} -configuration #{configuration} -sdk iphoneos"
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
      
      def deployment_url
        File.join(deploy_to, target.downcase, ipa_name)
      end
      
      def manifest_url
        File.join(deploy_to, target.downcase, "manifest.plist")
      end
      
      def remote_installation_path
        File.join(remote_directory, target.downcase)
      end
    end
    
    private
    
    def define
      namespace :beta do
        desc "Build the beta release of the app"
        task :build => :clean do
          system("xcodebuild #{@configuration.build_arguments} build")
        end
        
        task :clean do
          system("xcodebuild #{@configuration.build_arguments} clean")
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
            system("zip -r #{@configuration.ipa_name} Payload")
          end
          FileUtils.mkdir('pkg/dist')
          FileUtils.mv("pkg/#{@configuration.ipa_name}", "pkg/dist")
        end
        
        desc "Deploy the beta to your server"
        task :deploy => :package do
          @deployment_strategy.prepare
          @deployment_strategy.deploy
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
