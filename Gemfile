source 'https://rubygems.org'
gemspec :name => :camping

gem 'rake'

if rack = ENV['RACK']
  if rack == "master"
    gem 'rack', :git => 'git://github.com/rack/rack.git'
  else
    gem 'rack', rack
  end
end

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
end

