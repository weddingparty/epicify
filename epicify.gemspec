# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "epicify/version"

Gem::Specification.new do |s|
  s.name        = "epicify"
  s.version     = Epicify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Gordon McCreight", "Kaushik Gopal", "Guilherme Moura"]
  s.email       = ["gordon@weddingparty"]
  s.homepage    = ""
  s.summary     = %q{Add epic reporting to Asana projects}
  s.description = %q{Add epic reporting to Asana projects}
  s.license    = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
