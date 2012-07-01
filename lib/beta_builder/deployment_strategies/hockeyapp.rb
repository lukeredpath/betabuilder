require 'rest_client'
require 'json'
require 'tmpdir'
require 'fileutils'

# # Deployment strategy for [HockeyApp](http://hockeyapp.net)
#
# Example API upload:
#
# curl \
#   -F "status=2" \
#   -F "notify=1" \
#   -F "notes=Some new features and fixed bugs." \
#   -F "notes_type=0" \
#   -F "ipa=@hockeyapp.ipa" \
#   -F "dsym=@hockeyapp.dSYM.zip" \
#   -H "X-HockeyAppToken: 4567abcd8901ef234567abcd8901ef23" \
#   https://rink.hockeyapp.net/api/2/apps/1234567890abcdef1234567890abcdef/app_versions
#
module BetaBuilder
  module DeploymentStrategies
    class HockeyApp < Strategy

      def endpoint(app_id)
        "https://rink.hockeyapp.net/api/2/apps/#{app_id}/app_versions"
      end

      def extended_configuration_for_strategy
        proc do
          def generate_release_notes(&block)
            self.release_notes = block if block
          end
        end
      end

      # 1: Don't allow users to download or install the version
      # 2: Available for download or installation
      def status_flag(allow_download = false)
        allow_download ? 2 : 1
      end

      # 0 - Don't notify testers
      # 1 - Notify all testers that can install this app
      def notify_flag(notify = false)
        notify ? 1 : 0
      end

      def deploy
        release_notes = get_notes
        payload = {
          :status => status_flag(@configuration.allow_download)
          :ipa    => File.new(@configuration.ipa_path, 'rb'),
          :notes  => release_notes,
          :notify => notify_flag(@configuration.notify),
        }
        api_token = @configuration.api_token

        puts "Uploading build to Hockey App..."
        if @configuration.verbose
          puts "ipa path: #{@configuration.ipa_path}"
          puts "release notes: #{release_notes}"
          puts payload.inspect
        end

        if @configuration.dry_run
          puts '** Dry Run - No action here! **'
          puts payload.inspect
          return
        end

        begin
          response = RestClient.post(endpoint(@configuration.app_id), payload, {:accept => :json, "X-HockeyAppToken" => api_token})
        rescue => e
          response = e.response
        end

        if (response.code == 201) || (response.code == 200)
          puts "Upload complete."
        else
          puts "Upload failed. (#{response})"
        end
      end

      private

      def get_notes
        notes = @configuration.release_notes_text
        notes || get_notes_using_editor || get_notes_using_prompt
      end

      def get_notes_using_editor
        return unless (editor = ENV["EDITOR"])

        dir = Dir.mktmpdir
        begin
          filepath = "#{dir}/release_notes"
          system("#{editor} #{filepath}")
          @configuration.release_notes = File.read(filepath)
        ensure
          rm_rf(dir)
        end
      end

      def get_notes_using_prompt
        puts "Enter the release notes for this build (hit enter twice when done):\n"
        @configuration.release_notes = gets_until_match(/\n{2}$/).strip
      end

      def gets_until_match(pattern, string = "")
        if (string += STDIN.gets) =~ pattern
          string
        else
          gets_until_match(pattern, string)
        end
      end
    end
  end
end
