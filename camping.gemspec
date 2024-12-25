# require File.expand_path('../constants', __FILE__)
# camping_spec

NAME = "camping"
BRANCH = "3.2.6"
GIT = ENV['GIT'] || "git"
REV = `#{GIT} rev-list HEAD`.strip.split.length
VERS = ENV['VERSION'] || BRANCH

RDOC_OPTS = ["--line-numbers", "--quiet", "--main", "README"]

@spec ||= Gem::Specification.new do |s|
  s.name = NAME
  s.version = VERS
  s.licenses = ['MIT']
  s.platform = Gem::Platform::RUBY
  # s.extra_rdoc_files = FileList["README.md", "CHANGELOG", "COPYING", "book/*"].to_a
  s.rdoc_options += RDOC_OPTS + ['--exclude', '^(examples|extras)\/', '--exclude', 'lib/camping.rb']
  s.summary = "miniature rails for anyone"
  s.author = "why the lucky stiff"
  s.email = 'why@ruby-lang.org'
  s.homepage = 'http://rubycamping.org/'
  s.executables = ['camping']
  s.add_runtime_dependency('rake', '~> 13.2.1')
  s.add_runtime_dependency('mab', '~> 0.0', '>=0.0.3')
  s.add_runtime_dependency('tilt', '~> 2.3.0',)
  s.add_runtime_dependency('rack', '~> 3.0', '>= 3.0.4.1')
  s.add_runtime_dependency('rack-session', '~> 2.0', '>=2.0.0')
  s.add_runtime_dependency('rackup', '~> 2.1.0')
  s.add_runtime_dependency('kdl', '~> 2.0')
  s.add_runtime_dependency('zeitwerk', '~> 2.6.15', '>=2.6.15')
  s.add_runtime_dependency('listen', '~> 3.9.0', '>=3.9.0')
  s.add_runtime_dependency('dry-logger', '~> 1.0.4')

  s.add_development_dependency "bundler"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "minitest-global_expectations"
  s.add_development_dependency "minitest-sprint"

  s.required_ruby_version = '>= 3.1.2'

  s.files = %w(COPYING README.md Rakefile) +
    Dir.glob("{bin,doc,test,lib,extras,book}/**/*") +
    Dir.glob("ext/**/*.{h,c,rb}") +
    Dir.glob("examples/**/*.rb") +
    Dir.glob("tools/*.rb")

  s.require_path = "lib"
  s.bindir = "bin"
end
