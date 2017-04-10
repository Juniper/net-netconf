begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = Dir.glob('spec/**/*spec.rb')
  end

  task default: :spec
rescue LoadError
  desc 'RSpec rake task not available'
  task :features do
    abort 'RSpec rake task is not available. Be sure to install rspec as a gem'
  end
end