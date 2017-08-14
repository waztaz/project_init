require 'json'
require_relative 'node'

tree = RedditTree.new
tree_of_comments = tree.construct_structure
tree.print_in_order tree.root
require 'pry'; binding.pry
