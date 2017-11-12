require 'json'
require 'node'

tree = RedditTree.new
tree_of_comments = tree.construct_structure
# First layer is the top level subreddit - nothing interesting
# Second layer is the titles in the subreddit - useful
# Third layer are the comments themselves - in the nested fashion
x = tree_of_comments.to_custom_json
puts JSON.pretty_generate(x)
