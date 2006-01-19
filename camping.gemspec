# This gemspec is not recommended for install and is here
# as a stub to remind me that it's an option someday...
require 'rubygems'
spec = Gem::Specification.new do |s|
  s.name = 'camping'
  s.version = "1.1"
  s.platform = Gem::Platform::RUBY
  s.summary = "miniature rails for stay-at-home moms"
  s.add_dependency('activerecord')
  s.add_dependency('markaby')
  s.add_dependency('metaid')
  s.files = ['examples/**/*', 'lib/**/*', 'bin/**/*'].collect do |dirglob|
                Dir.glob(dirglob)
            end.flatten.delete_if {|item| item.include?(".svn")}
  s.require_path = 'lib'
  s.autorequire = 'camping'
  s.author = "why the lucky stiff"
  s.email = "why@ruby-lang.org"
  s.rubyforge_project = "hobix"
  s.homepage = "http://whytheluckystiff.net/camping/"
end
if $0==__FILE__
  Gem::Builder.new(spec).build
end
