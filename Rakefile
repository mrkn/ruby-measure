$LOAD_PATH.unshift 'lib'
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'

require 'measure/version'
dir = File.dirname(__FILE__)

PKG_NAME = 'measure'
PKG_VERSION = Measure::VERSION::STRING
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
  '[A-Z]*',
  'lib/**/*.rb',
  'spec/**/*',
]

task :default => [ :spec ]

require 'rspec/core/rake_task'
RSPEC_OPTIONS = [ '--backtrace', '--color' ].freeze
desc 'Run all specs'
RSpec::Core::RakeTask.new do |t|
  t.ruby_opts = [
    '-I', File.expand_path('lib'),
    '-I', File.expand_path('spec'),
  ]
  t.rspec_opts = [
    *RSPEC_OPTIONS,
    '--format', 'documentation',
    *(ENV["SPEC_OPTS"] || "").scan(/"(?:[^"]|\\")+"|'(?:[^']|\\')+'|\S+/)
  ]
  t.pattern = ENV["PATTERN"] if ENV["PATTERN"]
end

desc 'Run all specs and store html output in doc/output/report.html'
RSpec::Core::RakeTask.new('spec_html') do |t|
  t.ruby_opts = [
    '-I', File.expand_path('lib'),
    '-I', File.expand_path('spec'),
    '-w',
  ]
  t.rspec_opts = [
    *RSPEC_OPTIONS,
    '--format', 'html',
    *(ENV["SPEC_OPTS"] || "").scan(/"(?:[^"]|\\")+"|'(?:[^']|\\')+'|\S+/)
  ]
  t.pattern = ENV["PATTERN"] if ENV["PATTERN"]
end

desc 'Generate RDoc'
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = File.join('doc', 'rdoc')
  rdoc.options << '--title' << 'Measure' << '--line-numbers'
  rdoc.options << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include('README', 'CHANGES', 'COPYING', 'COPYING.LIB',
                          'lib/**/*.rb')
end

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = Measure::VERSION::SUMMARY
  s.description = <<-EOF
    Measure is a library to handle measurement numbers.
  EOF

  s.files = PKG_FILES.to_a
  s.require_path = 'lib'

  s.has_rdoc = true
  s.rdoc_options = rd.options
  s.extra_rdoc_files = rd.rdoc_files.reject {|fn| fn =~ /\.rb$/ }.to_a

  s.author = 'Kenta Murata'
  s.email = 'measure-devel@rubyforge.org'
  s.homepage = 'http://measure.rubyforge.org'
  s.platform = Gem::Platform::RUBY
  s.rubyforge_project = 'measure'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

def egrep(pattern)
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while l = f.gets
        count +=1
        puts "#{fn}:#{count}:#{line}" if line =~ pattern
      end
    end
  end
end

desc 'Look for TODO and FIXME tags in the code'
task :todo do
  egrep /(FIXME|TODO)/
end

task :verify_user do
  raise "RUBYFORGE_USER environment variable not set!" unless ENV['RUBYFORGE_USER']
end

desc 'Publish gem+tgz+zip on RubyForge.  You must make sure lib/version.rb is aligned with the ChangeLog file'
task :publish_packages => [ :verify_user, :package, :pkg ] do
  release_files = FileList[
    File.join('pkg', "#{PKG_FILE_NAME}.gem"),
    File.join('pkg', "#{PKG_FILE_NAME}.zip"),
    File.join('pkg', "#{PKG_FILE_NAME}.tgz"),
    'CHANGES'
  ]
  unless defined? Measure::VERSION::RELEASE_CANDIDATE and Measure::VERSION::RELEASE_CANDIDATE
    require 'meta_project'
    require 'rake/contrib/xforge'

    project = MetaProject::Project::XForge::RubyForge.new(PKG_NAME)
    Rake::XForge::Release.new(project) do |xf|
      # Never hardcode user name and password in the Rakefile!
      xf.user_name = ENV['RUBYFORGE_USER']
      xf.files = release_files.to_a
      xf.release_name = "Measure #{PKG_NAME}"
    end
  else
    puts 'SINCE THIS IS A PRERELEASE, FILES ARE UPLOADED WITH SSH, NOT TO THE RUBYFORGE FILE SECTION'
    puts 'YOU MUST TYPE THE PASSWORD #{release_files.length} TIMES...'

    host = 'measure-website@rubyforge.org'
    remote_dir = '/var/www/gforge-projects/#{PKG_NAME}'

    publisher = Rake::SshFilePublisher.new(
      host,
      remote_dir,
      File.dirname(__FILE__),
      *release_files)
    publisher.upload

    puts 'UPLOADED THE FOLLOWING FILES:'
    release_files.each do |fn|
      name = File.basename(fn)
      puts "* http://measure.rubyforge.org/#{name}"
    end

    puts "They are not linked to anywhere, so don't forget to tell people!"
  end
end

desc 'Publish news on RubyForge'
task :publish_news => [ :verify_user ] do
  unless defined? Measure::VERSION::RELEASE_CANDIDATE and Measure::VERSION::RELEASE_CANDIDATE
    require 'meta_project'
    require 'rake/contrib/xforge'

    project = MetaProject::Project::XForge::RubyForge.new(PKG_NAME)
    Rake::XForge::NewsPublisher.new(project) do |news|
      # Never hardcode user name and password in the Rakefile!
      news.user_name = ENV['RUBYFORGE_USER']
    end
  else
    puts '** Not publishing news to RubyForge because this is a prerelease'
  end
end
