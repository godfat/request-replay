# -*- encoding: utf-8 -*-
# stub: request-replay 0.7.1 ruby lib

Gem::Specification.new do |s|
  s.name = "request-replay"
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lin Jen-Shin (godfat)"]
  s.date = "2014-03-30"
  s.description = "Replay the request via Rack env"
  s.email = ["godfat (XD) godfat.org"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  ".travis.yml",
  "CHANGES.md",
  "Gemfile",
  "LICENSE",
  "README.md",
  "Rakefile",
  "lib/request-replay.rb",
  "lib/request-replay/middleware.rb",
  "lib/request-replay/proxy.rb",
  "lib/request-replay/test.rb",
  "request-replay.gemspec",
  "task/README.md",
  "task/gemgem.rb",
  "test/test_middleware.rb",
  "test/test_proxy.rb",
  "test/test_request-replay.rb"]
  s.homepage = "https://github.com/godfat/request-replay"
  s.licenses = ["Apache License 2.0"]
  s.rubygems_version = "2.2.2"
  s.summary = "Replay the request via Rack env"
  s.test_files = [
  "test/test_middleware.rb",
  "test/test_proxy.rb",
  "test/test_request-replay.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bacon>, [">= 0"])
      s.add_development_dependency(%q<muack>, [">= 0"])
      s.add_development_dependency(%q<rack>, [">= 0"])
    else
      s.add_dependency(%q<bacon>, [">= 0"])
      s.add_dependency(%q<muack>, [">= 0"])
      s.add_dependency(%q<rack>, [">= 0"])
    end
  else
    s.add_dependency(%q<bacon>, [">= 0"])
    s.add_dependency(%q<muack>, [">= 0"])
    s.add_dependency(%q<rack>, [">= 0"])
  end
end
