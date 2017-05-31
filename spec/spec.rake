begin
  require 'rspec/core/rake_task'
  #require 'ci/reporter/rake/rspec'

  desc 'Run all unittests with RSpec'
  task :spec => ['spec:unittests']

  namespace :spec do
    desc ""
    RSpec::Core::RakeTask.new(:unittests) do |t|
      t.pattern = 'spec/unittests/**/*_spec.rb'
    end
  end
rescue LoadError
  task :spec do
    abort 'rspec is not available. In order to run spec, you must: gem install rspec'
  end
end
