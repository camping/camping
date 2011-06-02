require 'rake'

NAME = "camping"
BRANCH = "2.1"
GIT = ENV['GIT'] || "git"
REV = `#{GIT} rev-list HEAD`.strip.split.length
VERS = ENV['VERSION'] || (REV.zero? ? BRANCH : [BRANCH, REV] * '.')

RDOC_OPTS = ["--line-numbers", "--quiet", "--main", "README"]

def spec
  @spec ||= Gem::Specification.new do |s|
    s.name = NAME
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    s.has_rdoc = true
    s.extra_rdoc_files = FileList["README", "CHANGELOG", "COPYING", "book/*"].to_a
    s.rdoc_options += RDOC_OPTS + ['--exclude', '^(examples|extras)\/', '--exclude', 'lib/camping.rb']
    s.summary = "minature rails for stay-at-home moms"
    s.author = "why the lucky stiff"
    s.email = 'why@ruby-lang.org'
    s.homepage = 'http://camping.rubyforge.org/'
    s.rubyforge_project = 'camping'
    s.executables = ['camping']

    s.add_dependency('rack', '>=1.0')
    s.required_ruby_version = '>= 1.8.2'

    s.files = %w(COPYING README Rakefile) +
      Dir.glob("{bin,doc,test,lib,extras,book}/**/*") +
      Dir.glob("ext/**/*.{h,c,rb}") +
      Dir.glob("examples/**/*.rb") +
      Dir.glob("tools/*.rb")

    s.require_path = "lib"
    s.bindir = "bin"
  end
end

def omni
  @omni ||= Gem::Specification.new do |s|
    s.name = "camping-omnibus"
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    s.summary = "the camping meta-package for updating ActiveRecord, Mongrel and SQLite3 bindings"
    %w[author email homepage rubyforge_project].each { |x| s.__send__("#{x}=", spec.__send__(x)) }

    s.add_dependency('camping', "=#{VERS}")
    s.add_dependency('activerecord')
    s.add_dependency('sqlite3', '>=1.1.0.1')
    s.add_dependency('mongrel')
    s.add_dependency('RedCloth')
    s.add_dependency('markaby')
  end
end

