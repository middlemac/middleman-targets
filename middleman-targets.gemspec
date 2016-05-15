# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'middleman-targets/version'

mm_needed = ['~> 4.1', '>= 4.1.7']

Gem::Specification.new do |s|
  s.name        = 'middleman-targets'
  s.version     = Middleman::MiddlemanTargets::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Jim Derry']
  s.email       = ['balthisar@gmail.com']
  s.homepage    = 'https://github.com/middlemac/middleman-targets'
  s.summary     = 'Provides multiple build targets and tools for Middleman.'
  s.description = 'Provides multiple build targets and tools for Middleman.'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  
  # The version of middleman-core your extension depends on
  s.add_runtime_dependency('middleman-core', mm_needed)

  # Additional dependencies
  s.add_runtime_dependency('middleman-cli', mm_needed)
  
  # Development dependencies
  s.add_development_dependency 'middleman', mm_needed
  s.add_development_dependency 'bundler',   '>= 1.6'
  s.add_development_dependency 'rake',      '>= 10.3'
  s.add_development_dependency 'git'
  s.add_development_dependency 'capybara', ['~> 2.5.0']
end
