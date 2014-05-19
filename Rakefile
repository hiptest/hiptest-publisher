# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "zest-publisher"
  gem.homepage = "https://www.zest-testing.com"
  gem.license = "GPL 2"
  gem.summary = "Export your tests from Zest into executable tests."
  gem.description = ""
  gem.email = "zest@smartesting.com"
  gem.authors = ["Smartesting R&D"]

  gem.executables = ['zest-publisher']
  gem.files = `git ls-files -- lib/*`.split("\n")
  gem.require_path = "lib"
  gem.add_runtime_dependency 'parseconfig', '~> 1.0', '>= 1.0.4'
  gem.add_runtime_dependency 'colorize', '~> 0.7', '>= 0.7.3'
  gem.add_runtime_dependency 'i18n', '~> 0.6', '>= 0.6.9'
  gem.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.2.1'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "zest-publisher #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
