require 'rake/tasklib'
require 'ostruct'
require 'fileutils'
require 'cfpropertylist'
require 'beta_builder/archived_build'

module BetaBuilder
  class Tasks < ::Rake::TaskLib
    def initialize(&block)
      @configuration = Configuration.new(
        :configuration => "Adhoc",
        :build_dir => "build",
        :auto_archive => false,
        :archive_path  => File.expand_path("~/Library/MobileDevice/Archived Applications/")
      )
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
          # if @configuration.auto_archive
          #   Rake::Task['beta:archive'].invoke
          # end
                    
          FileUtils.rm_rf('pkg') && FileUtils.mkdir_p('pkg')
          FileUtils.mkdir_p("pkg/Payload")
          FileUtils.mv(@configuration.built_app_path, "pkg/Payload/#{@configuration.app_name}")
          Dir.chdir("pkg") do
            system("zip -r #{@configuration.ipa_name} Payload")
          end
          FileUtils.mkdir('pkg/dist')
          FileUtils.mv("pkg/#{@configuration.ipa_name}", "pkg/dist")
          plist = CFPropertyList::List.new(:file => "pkg/Payload/#{@configuration.app_name}/Info.plist")
          plist_data = CFPropertyList.native_types(plist.value)
          File.open("pkg/dist/manifest.plist", "w") do |io|
            io << %{
              <?xml version="1.0" encoding="UTF-8"?>
              <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
              <plist version="1.0">
              <dict>
                <key>items</key>
                <array>
                  <dict>
                    <key>assets</key>
                    <array>
                      <dict>
                        <key>kind</key>
                        <string>software-package</string>
                        <key>url</key>
                        <string>#{@configuration.deployment_url}</string>
                      </dict>
                    </array>
                    <key>metadata</key>
                    <dict>
                      <key>bundle-identifier</key>
                      <string>#{plist_data['CFBundleIdentifier']}</string>
                      <key>bundle-version</key>
                      <string>#{plist_data['CFBundleVersion']}</string>
                      <key>kind</key>
                      <string>software</string>
                      <key>title</key>
                      <string>#{plist_data['CFBundleDisplayName']}</string>
                    </dict>
                  </dict>
                </array>
              </dict>
              </plist>
            }
          end
          File.open("pkg/dist/index.html", "w") do |io|
            io << %{
              <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
              <html xmlns="http://www.w3.org/1999/xhtml">
              <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
              <title>Beta Download</title>
              <style type="text/css">
              body {background:#fff;margin:0;padding:0;font-family:arial,helvetica,sans-serif;text-align:center;padding:10px;color:#333;font-size:16px;}
              #container {width:300px;margin:0 auto;}
              h1 {margin:0;padding:0;font-size:14px;}
              p {font-size:13px;}
              .link {background:#ecf5ff;border-top:1px solid #fff;border:1px solid #dfebf8;margin-top:.5em;padding:.3em;}
              .link a {text-decoration:none;font-size:15px;display:block;color:#069;}
              </style>
              </head>
              <body>
              <div id="container">
              <div class="link"><a href="itms-services://?action=download-manifest&url=#{@configuration.manifest_url}">Tap Here to Install<br />#{@configuration.target}<br />On Your Device</a></div>
              <p><strong>Link didn't work?</strong><br />
              Make sure you're visiting this page on your device, not your computer.</p>
              </body>
              </html>
            }
          end
        end
        
        desc "Deploy the beta to your server"
        task :deploy => :package do
          system("scp pkg/dist/* lukeredpath.co.uk:#{@configuration.remote_installation_path}")
        end
        
        # desc "Build and archive the app"
        # task :archive => :build do
        #   archive = BetaBuilder::ArchivedBuild.new(@configuration)
        #   archive.save_to(@configuration.archive_path)
        # end
      end
    end
  end
end
