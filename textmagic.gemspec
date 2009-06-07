# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{textmagic}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vladim\303\255r Bobe\305\241 Tu\305\276insk\303\275"]
  s.date = %q{2009-06-07}
  s.default_executable = %q{tm}
  s.description = %q{
      textmagic is a Ruby interface to the TextMagic's Bulk SMS Gateway.
      It can be used to easily integrate SMS features into your application.
      It supports sending messages, receiving replies and more.
      You need to have a valid TextMagic account to use this gem. You can get one at http://www.textmagic.com.
    }
  s.email = %q{vladimir.tuzinsky@gmail.com}
  s.executables = ["tm"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "History.txt",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "bin/tm",
     "lib/api.rb",
     "lib/charset.rb",
     "lib/error.rb",
     "lib/executor.rb",
     "lib/response.rb",
     "lib/textmagic.rb",
     "lib/validation.rb",
     "test/test_api.rb",
     "test/test_charset.rb",
     "test/test_error.rb",
     "test/test_executor.rb",
     "test/test_helper.rb",
     "test/test_response.rb",
     "test/test_validation.rb",
     "textmagic.gemspec"
  ]
  s.homepage = %q{http://github.com/bobes/textmagic}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{textmagic}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Ruby interface to the TextMagic's Bulk SMS Gateway}
  s.test_files = [
    "test/test_api.rb",
     "test/test_charset.rb",
     "test/test_error.rb",
     "test/test_executor.rb",
     "test/test_helper.rb",
     "test/test_response.rb",
     "test/test_validation.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0.4.3"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.5"])
      s.add_development_dependency(%q<fakeweb>, [">= 1.2.2"])
      s.add_development_dependency(%q<jeremymcanally-matchy>, [">= 0.1.0"])
    else
      s.add_dependency(%q<httparty>, [">= 0.4.3"])
      s.add_dependency(%q<mocha>, [">= 0.9.5"])
      s.add_dependency(%q<fakeweb>, [">= 1.2.2"])
      s.add_dependency(%q<jeremymcanally-matchy>, [">= 0.1.0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0.4.3"])
    s.add_dependency(%q<mocha>, [">= 0.9.5"])
    s.add_dependency(%q<fakeweb>, [">= 1.2.2"])
    s.add_dependency(%q<jeremymcanally-matchy>, [">= 0.1.0"])
  end
end
