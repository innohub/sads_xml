$:.push File.expand_path("../lib", __FILE__)

require "sads_xml/version"

Gem::Specification.new do |s|
  s.name        = "sads_xml"
  s.version     = SadsXml::VERSION
  s.authors     = ["Andrew Angelo Ang"]
  s.email       = ["dev@innohub.ph"]
  s.homepage    = "http://github.com/InnoHub/sads_xml"
  s.summary     = "Helpers for implenting services on Rails using Eyeline's Mobilizer product."
  s.description = "Helpers for implenting services on Rails using Eyeline's Mobilizer product."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "stringex"

  s.add_development_dependency "sqlite3"
end
