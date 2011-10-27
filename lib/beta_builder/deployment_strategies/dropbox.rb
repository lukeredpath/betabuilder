require 'tmpdir'
require 'fileutils'
require 'dropbox_sdk'

module BetaBuilder
  module DeploymentStrategies
    class Dropbox < Strategy
      DROPBOXURL = 'http://dl.dropbox.com/u/'
      def extended_configuration_for_strategy
        proc do          
          def deployment_url
            File.join(DROPBOXURL+user_id+deploy_to, ipa_name)
          end
          def webpage_url
            File.join(DROPBOXURL+user_id+deploy_to, "index.html")
          end          
          def manifest_url
            File.join(DROPBOXURL+user_id+deploy_to, "manifest.plist")
          end
        end
      end
      
      def prepare
        plist = CFPropertyList::List.new(:file => "pkg/Payload/#{@configuration.app_name}.app/Info.plist")
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
      
      
      def deploy
        puts "Uploading build to Dropbox..."
        
        if @configuration.dry_run 
          puts '** Dry Run - No action here! **'
          return
        end
        begin
          session = DropboxSession.deserialize(File.read('build/dropbox_saved_session.txt'))
          session.get_request_token
        rescue Exception => e
          session = DropboxSession.new(@configuration.consumer_key, @configuration.consumer_secret)
          session.get_request_token
          # Make the user log in and authorize this token
          authorize_url = session.get_authorize_url
          puts "AUTHORIZING", authorize_url
          `open "#{authorize_url}"`
          puts "Please visit that web page and hit 'Allow', then hit Enter here."
          STDIN.gets            
          session.get_access_token
          File.open('build/dropbox_saved_session.txt', 'w') do |f|
            f.puts session.serialize
          end
        end
        
        client = DropboxClient.new(session, :dropbox)
        # puts "linked account:", client.account_info().inspect
        puts "Almost there..."
        file = open('pkg/dist/index.html')
        response1 = client.put_file("/Public#{@configuration.deploy_to}/index.html", file, overwrite=true)
        # puts "uploaded:", response1.inspect
        puts "Just a few more seconds..."
        file = open('pkg/dist/manifest.plist')
        response2 = client.put_file("/Public#{@configuration.deploy_to}/manifest.plist", file, overwrite=true)
        # puts "uploaded:", response2.inspect
        puts "It's really close now..."
        file = open("pkg/dist/#{@configuration.ipa_name}")
        response3 = client.put_file("/Public#{@configuration.deploy_to}/#{@configuration.ipa_name}", file, overwrite=true)
        # puts "uploaded:", response3.inspect
        puts "Done!"
        
        puts "#{@configuration.webpage_url}"
        if @configuration.open_browser_when_done
          `open "#{@configuration.webpage_url}"`
        end
        
      end
      
    end
  end
end
