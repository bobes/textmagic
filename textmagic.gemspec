# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{textmagic}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vladimir Tuzinsky"]
  s.date = %q{2009-05-21}
  s.email = %q{vladimir.tuzinsky@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "lib/textmagic.rb",
     "test/test_helper.rb",
     "test/textmagic_test.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/bobes/textmagic}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{textmagic}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby interface to the TextMagic's SMS gateway}
  s.test_files = [
    "test/api_test.rb",
     "test/test_helper.rb",
     "test/textmagic_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
