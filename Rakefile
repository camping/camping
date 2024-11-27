$:.unshift 'extras'

begin
  require 'rake/dsl_definition'
  require 'rake/alt_system'
rescue LoadError
else
  begin
    if defined?(Rake::DeprecatedObjectDSL)
      Rake::DeprecatedObjectDSL.class_eval do
        private_instance_methods(false).each do |meth|
          remove_method meth
        end
      end
    end
  rescue Exception
  end
end

#$VERBOSE = nil
require 'bundler/gem_tasks'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'tempfile'
require 'open3'

# require File.expand_path('../constants', __FILE__)

CLEAN.include ['**/.*.sw?', '*.gem', '.config', 'test/test.log', '.*.pt']

task :default => :check

task :test => :default
# New Docs

## context for the docs sections: we're going to move to using Rdoc and yard.
## With some extras. The Docs folder will probably go away.

## New docs directly serve a website like a boss.
desc "Serves the docs locally"
task :serve do
  sh "ruby -run -e httpd docs -p 8000"
end

## RDoc
begin
  gem 'rdoc', '~>3.9.0'
rescue LoadError
  task :docs do
    puts "** Camping needs RDoc 3.9 in order to use the Flipbook template."
  end
else
  require 'rdoc/task'
  RDoc::Task.new(:docs) do |rdoc|
    # We have a recent version of RDoc, so let's use flipbook.
    require 'rdoc/generator/singledarkfish'
    rdoc.options += ['-f', 'singledarkfish', *RDOC_OPTS]
    rdoc.template = "flipbook"

    rdoc.rdoc_dir = 'doc'
    rdoc.title = "Camping, a Microframework"
    rdoc.rdoc_files.add ['README', 'lib/camping-unabridged.rb', 'lib/camping/**/*.rb', 'book/*']
  end
end


task :rubygems_docs do
  require 'rubygems/doc_manager'

  def spec.installation_path; '.' end
  def spec.full_gem_path;     '.' end
  manager = Gem::DocManager.new(spec)
  manager.generate_rdoc
end

desc "Packages Camping."
task :package => :clean

## Tests
namespace :test do

  Rake::TestTask.new(:camping) do |t|
    t.libs << "test"
    t.test_files = FileList['test/app_*.rb']
    t.verbose = false
  end

  Rake::TestTask.new(:gear) do |t|
    t.libs << "test"
    t.test_files = FileList['test/gear/gear_*.rb']
    t.verbose = nil
  end

  ## Reloader Tests
  Rake::TestTask.new(:reloader) do |t|
    t.libs << "test"
    t.test_files = FileList['test/reload_*.rb']
    t.verbose = nil
  end

  ## Config Reloader Tests
  Rake::TestTask.new(:configreloader) do |t|
    t.libs << "test"
    t.test_files = FileList['test/config_*.rb']
  end
  
  ## Command tests
  Rake::TestTask.new(:commands) do |t|
    t.libs << "test"
    t.test_files = FileList['test/commands/test_*.rb']
  end

  desc "Run Camping::Server tests"
  Rake::TestTask.new("server") do |t|
    t.libs << 'test/server'
    t.test_files = FileList["test/server/**/spec_*.rb"]
    t.warning = false
    t.verbose = false
  end

end

## Diff
desc "Compare camping and camping-unabridged"
task :diff do
  require 'parser/current'
  require 'unparser'
  require 'pp'
  u = Tempfile.new('unabridged')
  m = Tempfile.new('mural')

  usexp = Parser::CurrentRuby.parse(File.read("lib/camping-unabridged.rb"))
  msexp = Parser::CurrentRuby.parse(File.read("lib/camping.rb"))

  u << Unparser.unparse(usexp)
  m << Unparser.unparse(msexp)

  u.flush
  m.flush

  sh "diff -u #{u.path} #{m.path} | less"

  u.delete
  m.delete
end

error = false

## Check
task :check => ["test:camping", "test:gear", "test:reloader", "test:configreloader", "test:server", "check:valid", "check:equal", "check:size", "check:lines", "check:exit"]
namespace :check do

  desc "Check source code validity"
  task :valid do
    sh "ruby -c lib/camping.rb"
  end

  desc "Check equality between mural and unabridged"
  task :equal do
    require 'ruby_parser'
    u = RubyParser.new.parse(File.read("lib/camping-unabridged.rb"))
    m = RubyParser.new.parse(File.read("lib/camping.rb"))

    u.reject! do |sexp|
      sexp.is_a?(Sexp) and sexp[1] == s(:gvar, :$LOADED_FEATURES)
    end

    unless u == m
      STDERR.puts "camping.rb and camping-unabridged.rb are not synchronized."
      error = true
    else
      puts "✅ synchronized....."
    end
  end

  SIZE_LIMIT = 6144
  desc "Compare camping sizes to unabridged"
  task :size do
    FileList["lib/camping*.rb"].each do |path|
      s = File.size(path)
      puts "%21s : % 6d % 4d%%" % [File.basename(path), s, (100 * s / SIZE_LIMIT)]
    end
    if File.size("lib/camping.rb") > SIZE_LIMIT
      STDERR.puts "lib/camping.rb: file is too big (> #{SIZE_LIMIT})"
      error = true
    end
  end

  desc "Verify that line length doesn't exceed 80 (120) chars for camping.rb"
  task :lines do
    i = 1
    File.open("lib/camping.rb").each_line do |line|
      if line.size > 121 # 1 added for \n
        error = true
        STDERR.puts "lib/camping.rb:#{i}: line too long (#{line[-10..-1].inspect})"
      end
      i += 1
    end
  end

  task :exit do
    exit 1 if error
  end

end
