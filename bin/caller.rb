require 'rubygems'
require 'bundler/setup'
require 'json'
require 'node'

tree = RedditTree.new
tree_of_comments = tree.construct_structure
x = tree_of_comments.to_custom_json
puts JSON.pretty_generate(x)
