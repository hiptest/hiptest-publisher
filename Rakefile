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

require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "hiptest-publisher"
  gem.homepage = "https://hiptest.com"
  gem.license = "GPL-2.0"
  gem.summary = "Export your tests from HipTest into executable tests."
  gem.description = "Provides a command-line tool that generates Java, Python or Ruby code to run the tests."
  gem.email = "contact@hiptest.com"
  gem.authors = ["HipTest R&D"]

  gem.executables = ['hiptest-publisher']
  gem.files = `git ls-files -- lib/* config/*`.split("\n")
  gem.require_path = "lib"
end
Juwelier::RubygemsDotOrgTasks.new

# Backport PR flajann2/juwelier#9 for ruby 2.6
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6')
  require 'juwelier/gemspec_helper'
  class Juwelier
    class GemSpecHelper
      def parse
        data = to_ruby
        parsed_gemspec = nil
        Thread.new { parsed_gemspec = eval("$SAFE = 1\n#{data}", binding, path) }.join
        # Need to reset $SAFE to 0 as it is process global since ruby 2.6
        $SAFE = 0 if $SAFE == 1
        parsed_gemspec
      end
    end
  end
end

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

task default: :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hiptest-publisher #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
