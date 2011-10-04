# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ichiban/version"

Gem::Specification.new do |s|
  s.name        = "ichiban"
  s.version     = Ichiban::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jarrett Colby"]
  s.email       = ["jarrettcolby@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Static website compiler}
  s.description = %q{The most elegant way to compile static websites}

  s.rubyforge_project = "ichiban"
  
  s.add_dependency 'activesupport'
  s.add_dependency 'erubis'
  s.add_dependency 'maruku'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
