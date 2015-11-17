# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vim/version'

Gem::Specification.new do |spec|
  spec.name          = "vim"
  spec.version       = Vim::VERSION
  spec.authors       = ["jimxl"]
  spec.email         = ["tianxiaxl@gmail.com"]
  spec.summary       = %q{方便使用ruby来开发和管理vim}
  spec.description   = %q{方便使用ruby来开发和管理vim}
  spec.homepage      = "http://dreamcoder.info"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
