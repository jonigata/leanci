# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'leanci/version'

Gem::Specification.new do |spec|
  spec.name          = "leanci"
  spec.version       = Leanci::VERSION
  spec.authors       = ["Naoyuki Hirayama"]
  spec.email         = ["naoyuki.hirayama@gmail.com"]
  spec.description   = %q{minimal CI servant}
  spec.summary       = %q{minimal CI servant work with chef-like DSL}
  spec.homepage      = "https://github.com/jonigata/leanci"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "serverengine"
  spec.add_runtime_dependency "rb-inotify"
end
