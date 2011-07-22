require 'uuid'
require 'fileutils'

module BetaBuilder
  def self.archive(configuration)
    if configuration.xcode4_archive_mode
      Xcode4ArchivedBuild.new(configuration)
    else
      ArchivedBuild.new(configuration)
    end
  end
  
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
  
  class Xcode4ArchivedBuild
    def initialize(configuration)
      @configuration = configuration
    end
    
    def save_to(path)
      date_path = File.join(path, "#{Time.now.strftime('%Y-%m-%d')}")
      FileUtils.mkdir_p(date_path)
      archive_path = File.join(date_path, "#{@configuration.target}.xcarchive")
      FileUtils.mkdir(archive_path)
      FileUtils.cp_r(@configuration.built_app_path, archive_path)
      FileUtils.cp_r(@configuration.built_app_dsym_path, archive_path)
    end
  end
end
