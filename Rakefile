require 'bundler/gem_tasks'
require 'cucumber/rake/task'
require 'yard'

ENV['GEM_NAME'] = 'middleman-targets'

task :default => :test

Cucumber::Rake::Task.new(:test, 'Features that must pass') do |task|
  task.cucumber_opts = '--require features --color --tags ~@wip --strict --format QuietFormatter'
end


YARD::Rake::YardocTask.new(:yard) do |task|
  task.stats_options = ['--list-undoc']
end
