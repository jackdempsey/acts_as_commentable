require 'rake/testtask'

desc 'Test the acts_as_commentable plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task default: :test
