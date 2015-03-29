$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "digitalforce/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "digitalforce"
  s.version     = Digitalforce::VERSION
  s.authors     = ["Alexandre Moraes"]
  s.email       = ["alexandrecmoraes89@gmail.com.br"]
  s.homepage    = "http://github.com/kalvinmoraes/digitalforce"
  s.summary     = "A wrapper gem for the restforce."
  s.description = "A wrapper gem for the restforce."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  # Wrapper gem for Salesforce API requests
  s.add_runtime_dependency "restforce"

  s.add_development_dependency "pg"
end
