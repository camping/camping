require 'rubygems'
spec = Gem::Specification.new do |s|
  s.name = 'camping'
  s.version = "1.1"
  s.platform = Gem::Platform::RUBY
  s.summary = "miniature rails for stay-at-home moms"
  s.add_dependency('activerecord')
  s.add_dependency('markaby')
  s.add_dependency('metaid')
  s.has_rdoc = true
  s.files = ['README', 'examples/**/*', 'lib/**/*', 'bin/**/*'].collect do |dirglob|
                Dir.glob(dirglob)
            end.flatten.delete_if {|item| item.include?(".svn")}
  s.extra_rdoc_files = ['README']
  s.rdoc_options << "--title" << "Camping Documentation" << 
                    "--line-numbers" << 
                    "--inline-source" << 
                    "--main" << "README" <<
                    "--exclude" << "^examples\/" << 
                    "--exclude" << "lib/camping.rb"
  s.require_path = 'lib'
  s.autorequire = 'camping'
  s.author = "why the lucky stiff"
  s.email = "why@ruby-lang.org"
  s.rubyforge_project = "camping"
  s.homepage = "http://code.whytheluckystiff.net/camping/"
end
if $0==__FILE__
  Gem::Builder.new(spec).build
end
