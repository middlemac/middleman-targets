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


desc 'Make separate documents for documentation_project.'
task :partials do

  sections = [
      { :file => 'helpers.erb',          :group => 'Helpers',  },
      { :file => 'helpers_extended.erb', :group => 'Extended Helpers' },
      { :file => 'config.erb',           :group => 'Middleman Configuration' },
      { :file => 'resources.erb',        :group => 'Resource Extensions',  },
      { :file => 'instance.erb',         :group => 'Instance Methods',  },
  ]

  sections.each do |s|
    command = "yardoc --query 'o.group == \"#{s[:group]}\" || has_tag?(:author)' -o doc -t default -p #{File.join(File.dirname(__FILE__), 'yard', 'template-partials')}"
    puts command
    system(command)
    File.rename('doc/index.html', "doc/#{s[:file]}")
  end

end
