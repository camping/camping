# require File.expand_path('../constants', __FILE__)
# camping_omni

NAME = "camping"
BRANCH = "3.0.0"
GIT = ENV['GIT'] || "git"
REV = `#{GIT} rev-list HEAD`.strip.split.length
VERS = ENV['VERSION'] || BRANCH # (REV.zero? ? BRANCH : [BRANCH, REV] * '.')

RDOC_OPTS = ["--line-numbers", "--quiet", "--main", "README"]

def camping_spec
  @spec ||= Gem::Specification.new do |s|
    s.name = NAME
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    # s.extra_rdoc_files = FileList["README.md", "CHANGELOG", "COPYING", "book/*"].to_a
    s.rdoc_options += RDOC_OPTS + ['--exclude', '^(examples|extras)\/', '--exclude', 'lib/camping.rb']
    s.summary = "miniature rails for anyone"
    s.author = "why the lucky stiff"
    s.email = 'why@ruby-lang.org'
    s.homepage = 'http://camping.rubyforge.org/'
    s.executables = ['camping']
    s.add_runtime_dependency('rack', '~> 3.0', '>= 3.0.4.1')
    s.add_runtime_dependency('rack-session', '~> 2.0', '>=2.0.0')
    s.add_runtime_dependency('mab', '~> 0.0', '>=0.0.3')

    # Post Rack 3.0 dependencies.
    # s.add_runtime_dependency('rack', '~> 3.0', '>= 3.0.0')
    # s.add_runtime_dependency('rack-session', '~> 0.3', '>=0.3.0')
    # s.add_runtime_dependency('rackup', '~> 0.2', '>=0.2.2')
    s.required_ruby_version = '>= 2.5.3'

    s.files = %w(COPYING README.md Rakefile) +
      Dir.glob("{bin,doc,test,lib,extras,book}/**/*") +
      Dir.glob("ext/**/*.{h,c,rb}") +
      Dir.glob("examples/**/*.rb") +
      Dir.glob("tools/*.rb")

    s.require_path = "lib"
    s.bindir = "bin"
  end
end

camping_spec

def camping_omni
  @omni ||= Gem::Specification.new do |s|
    s.name = "camping-omnibus"
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    s.summary = "the camping meta-package for updating ActiveRecord, and SQLite3 bindings"
    %w[author email homepage].each { |x| s.__send__("#{x}=", camping_spec.__send__(x)) }

    s.add_dependency('camping', ">=#{BRANCH}")
    s.add_dependency('guidebook')
    s.add_dependency('sqlite3', '~> 1.4', '>= 1.4.4')
    s.add_dependency('cairn', '>= 7.1.0')
  end
end

camping_omni
