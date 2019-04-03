require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :console do
  exec 'irb -r BrocadeAPIClient -I ./lib'
end

namespace :build do
  begin
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new(:spec) do |t|
      puts '', 'RSpec Task started....'
      t.pattern = Dir.glob('spec/**/*_spec.rb')
      t.rspec_opts = '--format html --out test_reports/rspec_results.html'
      t.fail_on_error = true
    end

    task default: :spec
  rescue LoadError => le
    # no rspec available
    puts "(#{le.message})"
  end

  begin
    require 'rubocop/rake_task'
    desc 'Run RuboCop - Ruby static code analyzer'
    RuboCop::RakeTask.new(:rubocop) do |task|
      puts '', 'Rubocop Task started....'
      # task.patterns = ['lib/**/*.rb']
      task.fail_on_error = false
      task.formatters = ['html']
      task.options = ['--out', 'rubocop_report.html']
    end
  rescue LoadError => le
    # no rspec available
    puts "(#{le.message})"
  end
end
