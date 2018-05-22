namespace :test do
  require "rspec/core/rake_task"

  desc "Run RSpec code examples"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/**/test_*.rb"
    t.rspec_opts = ["--color", "--backtrace"]
  end

end
task :test => [:'test:unit']
