source :rubygems
gemspec :name => :camping

if rack = ENV['RACK']
  if rack == "master"
    gem 'rack', :git => 'git://github.com/rack/rack.git'
  else
    gem 'rack', rack
  end
end

group :extras do
  gem 'markaby'
end

