Gem::Specification.new do |s|
    s.name = NAME
    s.version = VERS
    s.platform = Gem::Platform::RUBY
    s.extra_rdoc_files = FileList["README.md", "CHANGELOG", "COPYING", "book/*"].to_a
    s.rdoc_options += RDOC_OPTS + ['--exclude', '^(examples|extras)\/', '--exclude', 'lib/camping.rb']
    s.summary = "miniature rails for anyone"
    s.author = "why the lucky stiff"
    s.email = 'why@ruby-lang.org'
    s.homepage = 'http://camping.rubyforge.org/'
    s.executables = ['camping']
    s.add_dependency('rack', '>=1.0')
    s.add_dependency('mab', '>=0.0.3')
    s.required_ruby_version = '>= 1.8.2'

    s.files = %w(COPYING README.md Rakefile) +
      Dir.glob("{bin,doc,test,lib,extras,book}/**/*") +
      Dir.glob("ext/**/*.{h,c,rb}") +
      Dir.glob("examples/**/*.rb") +
      Dir.glob("tools/*.rb")

    s.require_path = "lib"
    s.bindir = "bin"
end
