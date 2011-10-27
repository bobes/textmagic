require "rubygems"
require "rake"
require "rake/testtask"
require "rake/rdoctask"

Rake::TestTask.new(:test) do |test|
  test.libs << "lib" << "test"
  test.pattern = "test/**/test_*.rb"
  test.verbose = true
end
task :default => :test
