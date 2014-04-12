require 'rake'
require 'rake/testtask'
require 'rspec/core/rake_task'

task :default => [:spec]

Rake::TestTask.new do |t|
  t.pattern = 'testing/**/*_test.rb'
end

RSpec::Core::RakeTask.new do |t|
  t.pattern =  'testing/spec/**/*_spec.rb'
end
