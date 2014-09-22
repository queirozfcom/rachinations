require 'rake'
require 'rake/testtask'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

task :default => [:spec]

Rake::TestTask.new do |t|
  t.pattern = 'testing/**/*_test.rb'
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts= ['--default-path testing/spec','--color']
end


