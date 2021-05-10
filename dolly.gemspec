# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dolly/version"

Gem::Specification.new do |spec|
  spec.name          = "dolly"
  spec.version       = Dolly::VERSION
  spec.authors       = ["javierg"]
  spec.email         = ["javierg@amcoonline.net"]

  spec.description   = "couch adapter "
  spec.summary       = "will write something"
  spec.homepage      = "https://www.amco.me"

  spec.files         = Dir["README.md", "lib/**/*"]
  spec.test_files = Dir["test/**/*"]

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "oj"
  spec.add_dependency "curb", "0.9.8"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "test-unit-full"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "mocha"
end
