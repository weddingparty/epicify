require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end

desc "run coverage and send to coveralls"
task :cov do
  exec "COVERALLS_RUN_LOCALLY=1 rake"
end
