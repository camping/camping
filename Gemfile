source 'https://rubygems.org'

gem 'rake'
gem 'rack'
gem 'mab'

group :extras do
  gem 'tilt'
  if ENV['AR']
    gem 'activerecord', ENV['AR']
    gem 'sqlite3'
  end
end

group :development do
  gem 'parser'
  gem 'unparser'
end

group :test do
  gem 'minitest', '~> 5.0'
  gem 'rack-test'
  gem 'ruby_parser'
end

