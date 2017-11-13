require 'rubygems'
require 'bundler/setup'

desc 'Execute the code'
task :run do
  sh "ruby -I ./lib ./bin/caller.rb"
end

desc 'Store records in db'
task :store do
  sh "ruby -I ./lib ./bin/store.rb"
end

task :default => :run
