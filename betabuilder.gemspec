# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{betabuilder}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Luke Redpath"]
  s.date = %q{2010-11-02}
  s.email = %q{luke@lukeredpath.co.uk}
  s.extra_rdoc_files = ["README.md"]
  s.files = ["LICENSE", "README.md", "lib/beta_builder.rb", "lib/betabuilder.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://lukeredpath.co.uk}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A set of Rake tasks and utilities for managing iOS ad-hoc builds}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<CFPropertyList>, ["~> 2.0.0"])
    else
      s.add_dependency(%q<CFPropertyList>, ["~> 2.0.0"])
    end
  else
    s.add_dependency(%q<CFPropertyList>, ["~> 2.0.0"])
  end
end
