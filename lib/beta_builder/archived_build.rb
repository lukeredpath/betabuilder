require 'uuid'
require 'fileutils'

module BetaBuilder
  class ArchivedBuild
    def initialize(configuration)
      @configuration = configuration
      @uuid = UUID.generate.upcase
    end
    
    def save_to(path)
      archive_path = File.join(path, "#{@uuid}.apparchive")
      FileUtils.mkdir(archive_path)
      FileUtils.cp_r(@configuration.built_app_path, archive_path)
      FileUtils.cp_r(@configuration.built_app_dsym_path, archive_path)
    end
  end
end
