require 'rubygems'
begin
  require 'bundler/setup'
  require 'bundler'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
require 'rake'
require 'rake/rdoctask'

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Mailboxer"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb', 'app/**/*.rb')
end


Bundler::GemHelper.install_tasks
