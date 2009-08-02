$:.unshift 'extras'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'tempfile'
require 'open3'

task :default => :check

## Constants
NAME = "camping"
BRANCH = "1.9"
GIT = ENV['GIT'] || "git"
REV = `#{GIT} rev-list HEAD`.strip.split.length
VERS = ENV['VERSION'] || (REV.zero? ? BRANCH : [BRANCH, REV] * '.')

CLEAN.include ['**/.*.sw?', '*.gem', '.config', 'test/test.log', '.*.pt']
RDOC_OPTS = ['--title', "Camping, a Microframework",
    "--line-numbers",
    "--quiet",
    "--main", "README"]
    
## Packaging
spec =
  Gem::Specification.new do |s|
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

omni =
  Gem::Specification.new do |s|
    s.name = "camping-omnibus"
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    s.summary = "the camping meta-package for updating ActiveRecord, Mongrel and SQLite3 bindings"
    %w[author email homepage rubyforge_project].each { |x| s.__send__("#{x}=", spec.__send__(x)) }

    s.add_dependency('camping', "=#{VERS}")
    s.add_dependency('activerecord')
    s.add_dependency('sqlite3-ruby', '>=1.1.0.1')
    s.add_dependency('mongrel')
    s.add_dependency('acts_as_versioned')
    s.add_dependency('RedCloth')
  end
  
## RDoc

gem 'rdoc', '~> 2.4.0' rescue nil
require 'rdoc'

if defined?(RDoc::VERSION) && RDoc::VERSION[0,3] == "2.4"
  require 'rdoc/generator/singledarkfish'
  require 'rdoc/generator/book'
  require 'rdoctask'

  Camping::RDocTask.new(:rdoc) do |rdoc|
    rdoc.before_running_rdoc do
      mv "lib/camping.rb", "lib/camping-mural.rb"
      mv "lib/camping-unabridged.rb", "lib/camping.rb"
    end
    
    rdoc.after_running_rdoc do
      mv "lib/camping.rb", "lib/camping-unabridged.rb"
      mv "lib/camping-mural.rb", "lib/camping.rb"
    end
    
    rdoc.rdoc_dir = 'doc/api'
    rdoc.options += ['-f', 'singledarkfish', *RDOC_OPTS]
    rdoc.template = "flipbook"
    rdoc.title = "Camping, the Reference"
    rdoc.rdoc_files.add ['lib/camping.rb', 'lib/camping/**/*.rb']
  end

  Camping::RDocTask.new(:readme) do |rdoc|
    rdoc.rdoc_dir = 'doc'
    rdoc.options += RDOC_OPTS
    rdoc.template = "flipbook"
    rdoc.title = "Camping, a Microframework"
    rdoc.rdoc_files.add ['README']
  end

  Camping::RDocTask.new(:book) do |rdoc|
    rdoc.rdoc_dir = 'doc/book'
    rdoc.options += ['-f', 'book', *RDOC_OPTS]
    rdoc.template = "flipbook"
    rdoc.title = "Camping, the Book"
    rdoc.rdoc_files.add ['book/*']
  end

  desc "Build full documentation."
  task :docs => [:readme, :rdoc, :book]
  desc "Rebuild full documentation."
  task :redocs => [:rereadme, :rerdoc, :rebook]
  desc "Remove full documentation."
  task :clobber_docs => [:clobber_readme, :clobber_rdoc, :clobber_book]

  %w(docs redocs clobber_docs).each do |task_name|
    task = Rake::Task[task_name]
    task.prerequisites.each do |pre|
      Rake::Task[pre].instance_eval { @comment = nil }
    end
  end
  
  task :rubygems_docs do
    require 'rubygems/doc_manager'
    
    def spec.installation_path; '.' end
    def spec.full_gem_path;     '.' end
    manager = Gem::DocManager.new(spec)
    manager.generate_rdoc
  end
end

desc "Packages Camping."
task :package => :clean

Rake::GemPackageTask.new(spec) do |p|
  p.need_tar = true
  p.gem_spec = spec
end

Rake::GemPackageTask.new(omni) do |p|
  p.gem_spec = omni
end

task :install => :package do
  sh %{sudo gem install pkg/#{NAME}-#{VERS}}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end

## Tests
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/test_*.rb']
#  t.warning = true
#  t.verbose = true
end

## Diff
desc "Compare camping and camping-unabridged"
task :diff do
  require 'ruby2ruby'
  require 'ruby_parser'
  u = Tempfile.new('unabridged')
  m = Tempfile.new('mural')
  
  u << Ruby2Ruby.new.process(RubyParser.new.parse(File.read("lib/camping.rb")))
  m << Ruby2Ruby.new.process(RubyParser.new.parse(File.read("lib/camping-unabridged.rb")))
  
  sh "diff -u #{u.path} #{m.path} | less"
  
  u.delete
  m.delete
end

## Check
task :check => ["check:valid", "check:size", "check:lines"]
namespace :check do

  desc "Check source code validity"
  task :valid do
    require 'ruby_parser'
    u = RubyParser.new.parse(File.read("lib/camping-unabridged.rb"))
    m = RubyParser.new.parse(File.read("lib/camping.rb"))
    
    unless u == m
      STDERR.puts "camping.rb and camping-unabridged.rb are not synchronized."
    end
  end

  SIZE_LIMIT = 4096
  desc "Compare camping sizes to unabridged"
  task :size do
    FileList["lib/camping*.rb"].each do |path|
      s = File.size(path)
      puts "%21s : % 6d % 4d%" % [File.basename(path), s, (100 * s / SIZE_LIMIT)]
    end
    if File.size("lib/camping.rb") > SIZE_LIMIT
      STDERR.puts "lib/camping.rb: file is too big (> #{SIZE_LIMIT})"
    end
  end

  desc "Verify that line lenght doesn't exceed 80 chars for camping.rb"
  task :lines do
    i = 1
    File.open("lib/camping.rb").each_line do |line|
      if line.size > 81 # 1 added for \n
        STDERR.puts "lib/camping.rb:#{i}: line too long (#{line[-10..-1].inspect})"
      end
      i += 1
    end
  end

end
