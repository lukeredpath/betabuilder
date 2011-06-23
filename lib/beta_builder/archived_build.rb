require 'uuid'
require 'fileutils'

module BetaBuilder
  class ArchivedBuild
    def initialize(configuration)
      @configuration = configuration
      @uuid = UUID.generate.upcase
    end
    
    def save_to(path)
      if @configuration.xcode4_archive_mode
        date_path = File.join(path, "#{Time.now.strftime('%Y-%m-%d')}")
        FileUtils.mkdir_p(date_path)
        archive_path = File.join(date_path, "#{@configuration.target}.xcarchive")
      else
        archive_path = File.join(path, "#{@uuid}.apparchive")
      end
      
      FileUtils.mkdir(archive_path)
      FileUtils.cp_r(@configuration.built_app_path, archive_path)
      FileUtils.cp_r(@configuration.built_app_dsym_path, archive_path)
    end
  end
end
