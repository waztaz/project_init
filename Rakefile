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

desc 'Run sentiment analysis'
task :sentiment do
  sh "ruby -I ./lib ./bin/sentiment_analysis.rb"
end

task :default => :run
