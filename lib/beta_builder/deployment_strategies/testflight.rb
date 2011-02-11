require 'rest_client'
require 'json'
require 'tmpdir'
require 'fileutils'

module BetaBuilder
  module DeploymentStrategies
    class TestFlight < Strategy
      ENDPOINT = "http://testflightapp.com/api/builds.json"
      
      def extended_configuration_for_strategy
        proc do
          def generate_release_notes(&block)
            self.release_notes = yield if block_given?
          end
        end
      end
      
      def deploy
        payload = {
          :api_token          => @configuration.api_token,
          :team_token         => @configuration.team_token,
          :file               => File.new(@configuration.ipa_path, 'rb'),
          :notes              => get_notes,
          :distribution_lists => (@configuration.distribution_lists || []).join(","),
          :notify             => @configuration.notify || false
        }
        puts "Uploading build to TestFlight..."
        
        begin
          response = RestClient.post(ENDPOINT, payload, :accept => :json)
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
        @configuration.release_notes || get_notes_using_editor || get_notes_using_prompt
      end
      
      def get_notes_using_editor
        return unless (editor = ENV["EDITOR"])

        dir = Dir.mktmpdir
        begin
          filepath = "#{dir}/release_notes"
          system("#{editor} #{filepath}")
          notes = File.read(filepath)
        ensure
          rm_rf(dir)
        end
      end
      
      def get_notes_using_prompt
        puts "Enter the release notes for this build (hit enter twice when done):\n"
        gets_until_match(/\n{2}$/).strip
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
