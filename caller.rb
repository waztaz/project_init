require 'json'
require_relative 'lib/node'

tree = RedditTree.new
tree_of_comments = tree.construct_structure
x = tree_of_comments.to_custom_json
puts JSON.pretty_generate(x)
