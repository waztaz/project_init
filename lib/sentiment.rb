require 'base'
require 'htmlentities'

EachComment = Struct.new(:body, :score)

NUMBER_OF_ARTICLES = 5.freeze
COMMENTS_LIMIT = 100.freeze
COMMENTS_DEPTH = 12.freeze

@html_entity = HTMLEntities.new

def construct_structure
  base = Base.new
  all_comments = []
  links_array = base.top_news_today NUMBER_OF_ARTICLES
  link_ids = links_array.map { |link| link.id }
  link_ids.each do |link_id|
    all_comments_for_link = []
    all_comment_trees = base.get_all_comments link_id, COMMENTS_DEPTH, COMMENTS_LIMIT
    all_comment_trees.each do |comment_tree|
      all_comments_for_link << comments_tree_to_array(comment_tree)
    end
    all_comments << all_comments_for_link
  end
  all_comments.flatten
end

def comments_tree_to_array node
  all_comments = []
  if node.nil?
    return []
  else
    comment = node.comment
    body = @html_entity.decode(comment.body)
    all_comments << EachComment.new(body, comment.score)
    all_replies = node.replies
    if all_replies.nil?
      return all_comments
    end
    all_replies.each do |reply|
      all_comments << comments_tree_to_array(reply)
    end
    return all_comments
  end
end
