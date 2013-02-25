require 'uuid'
require 'fileutils'
require 'CFPropertyList'

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
      archive_path
    end
  end
  
  class Xcode4ArchivedBuild
    def initialize(configuration)
      @configuration = configuration
    end
    
    def archive_file_name
      "#{@configuration.archive_name} #{Time.now.strftime('%Y-%m-%d %H.%M')}.xcarchive"
    end
    
    def archive_path_within(path)
      File.join(path, "#{Time.now.strftime('%Y-%m-%d')}", archive_file_name)
    end
    
    def applications_path
      File.join("Products", "Applications")
    end
    
    def dsyms_path
      "dSYMs"
    end
    
    def plist_info_path
      File.join(@configuration.built_app_path, "Info.plist")
    end
    
    def save_to(path)
      archive_path = archive_path_within(path)
      FileUtils.mkdir_p(archive_path)
      
      application_path = File.join(archive_path, applications_path)
      FileUtils.mkdir_p(application_path)
      FileUtils.cp_r(@configuration.built_app_path, application_path)
      
      dsym_path = File.join(archive_path, dsyms_path)
      FileUtils.mkdir_p(dsym_path)
      FileUtils.cp_r(@configuration.built_app_dsym_path, dsym_path)
      
      write_plist_to(archive_path)
      archive_path
    end
    
    private
    
    def ios5_style_icon_paths
      return nil if metadata['CFBundleIcons'].nil?
      metadata['CFBundleIcons']['CFBundlePrimaryIcon']['CFBundleIconFiles']
    end
    
    def generic_icon_paths
      metadata['CFBundleIconFiles']
    end
      
    def icon_paths
      paths = ios5_style_icon_paths || generic_icon_paths || []
      paths.map {|file| File.join("Applications", @configuration.app_file_name, file) }
    end
 
    def write_plist_to(path)
      version = metadata["CFBundleShortVersionString"] || metadata["CFBundleVersion"]
      plist = {
        "ApplicationProperties" => {
          "ApplicationPath"             => File.join("Applications", @configuration.app_file_name),
          "CFBundleIdentifier"          => metadata["CFBundleIdentifier"], 
          "CFBundleShortVersionString"  => version, 
          "IconPaths"                   => icon_paths
        }, 
        "ArchiveVersion" => 1.0, 
        "Comment"        => @configuration.release_notes_text,
        "CreationDate"   => Time.now, 
        "Name"           => @configuration.archive_name, 
        "SchemeName"     => @configuration.scheme
      }
      File.open(File.join(path, "Info.plist"), "w") do |io|
        io.write plist.to_plist(:convert_unknown_to_string => true)
      end
    end
    
    def metadata
      @metadata ||= load_property_list(plist_info_path)
    end
    
    def load_property_list(path)
      plist = CFPropertyList::List.new(:file => path)
      CFPropertyList.native_types(plist.value)
    end
  end
end
