# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'colorize'

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

task :do_release do
  version = File.open('VERSION').read

  if File.readlines("CHANGELOG.md").grep(/Nothing changed yet/).size > 0
    header = "Changelog has not been updated since last release.".red
    commits =  `git log $(git describe --tags --abbrev=0)..HEAD --oneline`
    abort("#{header}\nHere are the commit messages to help you fill that:\n\n#{commits}")
  end

  Rake::Task["prerelease_changelog_update"].invoke
  `git commit CHANGELOG.md -m "Update changelog before release #{version}"`

  Rake::Task["release"].invoke

  Rake::Task["postrelease_changelog_update"].invoke
  `git commit CHANGELOG.md -m "Update changelog after release #{version}"`
  `git push`
end

task :prerelease_changelog_update do
  version = File.open('VERSION').read
  header_line = -2
  new_changelog = ""

  File.readlines('CHANGELOG.md').each_with_index do |line, index|
    if line == "[Unreleased]\n"
      new_changelog << "[#{version}]\n"
      header_line = index
    elsif line.start_with?('[Unreleased]')
      new_changelog << line
        .gsub('Unreleased', version)
        .gsub('master', "v#{version}")
        .gsub(' ', '     ')
    elsif index == header_line + 1
      new_changelog << ("-" * (version.length + 2)) + "\n"
    else
      new_changelog << line
    end
  end

  File.write('CHANGELOG.md', new_changelog)
end

task :postrelease_changelog_update do
  version = File.open('VERSION').read
  new_changelog = ""
  changes_header = -2

  File.readlines('CHANGELOG.md').each_with_index do |line, index|
    if line == "[#{version}]\n"
      new_changelog << [
        '[Unreleased]',
        '------------',
        '',
        ' - Nothing changed yet',
        '',
        ''
      ].join("\n")
    elsif line =="<!-- List of releases -->\n"
      changes_header = index
    elsif index == changes_header + 1
      new_changelog << "[Unreleased]: https://github.com/hiptest/hiptest-publisher/compare/v#{version}...master\n"
    end

    new_changelog << line
  end

  File.write('CHANGELOG.md', new_changelog)
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hiptest-publisher #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
