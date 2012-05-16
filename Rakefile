require "rubygems"
require "rubygems/package_task"
require "rdoc/task"

SITE_ROOT  = "/var/www/projects.lukeredpath.co.uk/betabuilder"

task :default => :package

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "betabuilder"
  s.version           = "0.7.4.1"
  s.summary           = "A set of Rake tasks and utilities for managing iOS ad-hoc builds"
  s.author            = "Luke Redpath"
  s.email             = "luke@lukeredpath.co.uk"
  s.homepage          = "http://github.com/lukeredpath/betabuilder"

  s.has_rdoc          = false
  s.extra_rdoc_files  = %w(README.md LICENSE CHANGES.md)
  s.rdoc_options      = %w(--main README.md)

  # Add any extra files to include in the gem
  s.files             = %w(CHANGES.md LICENSE README.md) + Dir.glob("{lib/**/*}")
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("CFPropertyList", "~> 2.0.0")
  s.add_dependency('uuid', "~> 2.3.1")
  s.add_dependency('rest-client', '~> 1.6.1')
  s.add_dependency('json')

  # If your tests use any gems, include them here
  # s.add_development_dependency("mocha") # for example
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more 
# about that here: http://gemcutter.org/pages/gem_docs
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

task :package => :gemspec

# Generate documentation
RDoc::Task.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end

desc 'Build and release to Rubygems.org'
task :release => :package do
  gem_path = File.join('pkg', spec.file_name)
  system "gem push #{gem_path}"
end

desc 'Build and install the gem'
task :install => :package do
  gem_path = File.join('pkg', spec.file_name)
  system("gem install #{gem_path}")
end

namespace :website do
  desc "Deploy to production"
  task :deploy => [:upload_website]

  desc "Regenerate the site"
  task :generate do
    Dir.chdir("website") do
      system("jekyll")
    end
  end
    
  task :upload_website => [:generate] do
    system("rsync -avz --delete website/_site/ lukeredpath.co.uk:#{SITE_ROOT}")
  end
  
  task :dev do
    Dir.chdir("website") do
      system("jekyll --auto")
    end
  end
end

# BetaBuilder tasks for testing

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[lib]))
require 'rubygems'
require 'betabuilder'

BetaBuilder::Tasks.new do |config|
  config.project_file_path = File.expand_path("~/Code/mine/squeemote/project/Squeemote.xcodeproj")
  config.target = "Squeemote"
  config.configuration = "Adhoc" 
  config.deploy_using(:web) do
  end
end

BetaBuilder::Tasks.new(:custom_namespace) do |config|
  config.target = "TestApp"
  config.configuration = "Custom" 
end
