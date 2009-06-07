require 'rubygems'
require 'rake'
require 'sdoc'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "textmagic"
    gem.summary = %Q{Ruby interface to the TextMagic's Bulk SMS Gateway}
    gem.description = %Q{
      textmagic is a Ruby interface to the TextMagic's Bulk SMS Gateway.
      It can be used to easily integrate SMS features into your application.
      It supports sending messages, receiving replies and more.
      You need to have a valid TextMagic account to use this gem. You can get one at http://www.textmagic.com.
    }
    gem.email = "vladimir.tuzinsky@gmail.com"
    gem.homepage = "http://github.com/bobes/textmagic"
    gem.authors = ["Vladimír Bobeš Tužinský"]
    gem.rubyforge_project = "textmagic"
    gem.add_runtime_dependency "httparty", ">= 0.4.3"
    gem.add_development_dependency "mocha", ">= 0.9.5"
    gem.add_development_dependency "fakeweb", ">= 1.2.2"
    gem.add_development_dependency "jeremymcanally-matchy", ">= 0.1.0"
  end

  Jeweler::RubyforgeTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end


task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "textmagic #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << '--charset' << 'utf8'
  rdoc.options << '--fmt' << 'shtml'
  rdoc.template = 'direct'
end

desc "Build, commit and publish the RDOC files"
task :doc => :rerdoc do
  cmd = <<-EOS
  echo 'Packing and deleting rdoc directory'
  tar -cf rdoc.tar rdoc
  rm -rf rdoc
  echo 'Checking out gh-pages branch'
  git checkout -m gh-pages
  echo 'Replacing rdoc directory'
  rm -rf rdoc
  tar -xf rdoc.tar
  rm rdoc.tar
  echo 'Commiting'
  git add rdoc
  git commit -m 'Updated RDoc'
  echo 'Pushing to origin'
  git push origin gh-pages
  EOS

  system cmd.split(/\n\s*/).join(' && ')

  system <<-EOS
  echo 'Checking out master'
  git checkout master
  echo 'Done'
  EOS
end
