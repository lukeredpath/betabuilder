desc "Generate documentation via Appledoc"
task :docs => 'docs:generate'

module BetaBuilder
  class AppleDoc
    def initialize(configuration)
      @configuration = configuration
    end
   
    def apple_doc_command
      "/usr/local/bin/appledoc -o Docs/API -p #{@configuration.app_name}" 
    end
  
    def generate
      command = apple_doc_command << " --no-create-docset --keep-intermediate-files --create-html ."
      system command
      puts "Generated HTML documentationa at Docs/API/html"
    end
         
    def install
      command = apple_doc_command << " --install-docset ."
       system command
    end
  end
end
