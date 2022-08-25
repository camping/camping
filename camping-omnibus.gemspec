# require File.expand_path('../constants', __FILE__)
# camping_omni

require 'rake'

NAME = "camping"
BRANCH = "2.3"
GIT = ENV['GIT'] || "git"
REV = `#{GIT} rev-list HEAD`.strip.split.length
VERS = ENV['VERSION'] || (REV.zero? ? BRANCH : [BRANCH, REV] * '.')

RDOC_OPTS = ["--line-numbers", "--quiet", "--main", "README"]

def camping_omni
  @omni ||= Gem::Specification.new do |s|
    s.name = "camping-omnibus"
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    s.summary = "the camping meta-package for updating ActiveRecord, and SQLite3 bindings"
    %w[author email homepage].each { |x| s.__send__("#{x}=", camping_spec.__send__(x)) }

    s.add_dependency('camping', ">=#{BRANCH}")
    s.add_dependency('activerecord')
    s.add_dependency('sqlite3', '>=1.1.0.1')
  end
end

camping_omni
