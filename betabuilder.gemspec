# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{betabuilder}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Luke Redpath}]
  s.date = %q{2011-06-17}
  s.email = %q{luke@lukeredpath.co.uk}
  s.extra_rdoc_files = [%q{README.md}, %q{LICENSE}, %q{CHANGES.md}]
  s.files = [%q{CHANGES.md}, %q{LICENSE}, %q{README.md}, %q{lib/beta_builder/archived_build.rb}, %q{lib/beta_builder/deployment_strategies/testflight.rb}, %q{lib/beta_builder/deployment_strategies/web.rb}, %q{lib/beta_builder/deployment_strategies.rb}, %q{lib/beta_builder.rb}, %q{lib/betabuilder.rb}]
  s.homepage = %q{http://github.com/lukeredpath/betabuilder}
  s.rdoc_options = [%q{--main}, %q{README.md}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{A set of Rake tasks and utilities for managing iOS ad-hoc builds}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<CFPropertyList>, ["~> 2.0.0"])
      s.add_runtime_dependency(%q<uuid>, ["~> 2.3.1"])
      s.add_runtime_dependency(%q<rest-client>, ["~> 1.6.1"])
      s.add_runtime_dependency(%q<json>, ["~> 1.4.6"])
    else
      s.add_dependency(%q<CFPropertyList>, ["~> 2.0.0"])
      s.add_dependency(%q<uuid>, ["~> 2.3.1"])
      s.add_dependency(%q<rest-client>, ["~> 1.6.1"])
      s.add_dependency(%q<json>, ["~> 1.4.6"])
    end
  else
    s.add_dependency(%q<CFPropertyList>, ["~> 2.0.0"])
    s.add_dependency(%q<uuid>, ["~> 2.3.1"])
    s.add_dependency(%q<rest-client>, ["~> 1.6.1"])
    s.add_dependency(%q<json>, ["~> 1.4.6"])
  end
end
