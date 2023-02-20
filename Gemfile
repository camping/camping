source 'https://rubygems.org'

gem 'rake'
gem 'rack'
gem 'rack-session'
gem 'rackup'
gem 'mab'
gem 'kdl' # for settings and default config stuff

group :extras do
  gem 'tilt'
  if ENV['AR']
    gem 'cairn'
    gem 'guidebook'
  end
end

group :development do
  gem 'parser'
  gem 'unparser'
end

group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-reporters'
  gem 'rack-test'
  gem 'ruby_parser'
end

