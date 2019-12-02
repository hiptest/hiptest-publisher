source 'https://rubygems.org'

gem 'colorize', '~> 0.7', '>= 0.7.5'
gem 'parseconfig', '~> 1.0', '>= 1.0.4'
gem 'i18n', '~> 0.7', '>= 0.7.0'
gem 'nokogiri', '~> 1.10'
gem 'multipart-post', '~> 2.1', '>= 2.1.1'
gem 'ruby_version', '~> 1'

if ENV['RUBY_HANDLEBARS_GEM_PATH']
  gem 'ruby-handlebars', path: ENV['RUBY_HANDLEBARS_GEM_PATH']
else
  gem 'ruby-handlebars', '~> 0.4.0'
end

group :development do
  gem 'pry', '~> 0'
  gem 'pry-byebug', '~> 3'
  gem 'rspec', '~> 3.3'
  gem 'rspec-mocks', '~> 3.3'
  gem 'codeclimate-test-reporter', '~> 0.4', '>= 0.4.6'
  gem 'i18n-tasks', '~> 0.9.29'
  gem 'i18n-coverage', '~> 0.1.1'
end

group :packaging do
  gem 'juwelier'
end

group :test do
  gem 'webmock'
  gem 'rspec_junit_formatter'
end
