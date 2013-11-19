# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dolly/version'

Gem::Specification.new do |spec|
  spec.name          = "dolly"
  spec.version       = Dolly::VERSION
  spec.authors       = ["javierg"]
  spec.email         = ["javierg@amcoonline.net"]
  spec.description   = "couch adapter "
  spec.summary       = "will write something"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.test_files = Dir["test/**/*"]

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 4.0.0"
  spec.add_dependency "httparty"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "fakeweb", "~> 1.3.0"
  spec.add_development_dependency "factory_girl_rails", "~> 4.2"
  spec.add_development_dependency "mocha", "~> 0.4"

end
