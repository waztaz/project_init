require_relative 'base'

class Node
  attr_accessor :children_nodes
  attr_accessor :score
  attr_accessor :fullname

  DEFAULT_ARGS = {
    "children_nodes" => [],
    "score" => 0,
    "fullname" => 'undefined'
  }
  
  def initialize args={}
    args = DEFAULT_ARGS.merge(args)
    @children_nodes ||= args["children_nodes"]
    @score ||= args["score"]
    @fullname ||= args["fullname"]
  end

  def append_child child
    @children_nodes << child
  end

  def to_custom_json
    if @children_nodes.empty?
      return {name: @fullname, score: @score}
    end
    children_json = []
    @children_nodes.each do |child_node|
      as_json = child_node.to_custom_json
      children_json << as_json
    end
    return {name: @fullname, score: @score, children: children_json}
  end
end

class RedditTree
  attr_accessor :root

  def initialize
    @client = Base.new
    @root = Node.new
  end

  def construct_structure
    count = 0
    get_all_news_lists = @client.all_news_today
    get_all_news_lists.each do |news|
      count += 1
      break if count > 10
      opts = {
        "fullname" => news.name, 
        "score" => news.score,
        "children_nodes" => []
      }
      node = Node.new(opts)
      @root.append_child(node)
    end
    all_links = @root.children_nodes
    all_links.each do |child_link_node|
      id = convert_fullname_to_id child_link_node.fullname
      comments_tree = @client.get_all_comments id, 4, 10
      comments_tree.each do |comment_tree|
        node_tree = convert_comment_tree_to_node_tree(comment_tree)
        child_link_node.append_child(node_tree)
      end
    end
    @root
  end

  def convert_comment_tree_to_node_tree comment_tree
    if comment_tree.replies.nil?
      comment = comment_tree.comment
      opts = {
        "fullname" => comment.name,
        "score" => comment.score,
        "children_nodes" => []
      }
      return Node.new(opts)
    else
      children_comments = comment_tree.replies
      comment = comment_tree.comment
      children_nodes = []
      children_comments.each do |child_comment|
        children_nodes << convert_comment_tree_to_node_tree(child_comment)
      end
      opts = {
        "fullname" => comment.name,
        "score" => comment.score,
        "children_nodes" => children_nodes
      }
      return Node.new(opts)
    end
  end

  def print_in_order node
    if node.children_nodes.empty?
      return "#{node.fullname} "
    else
      str = "#{node.fullname} "
      node.children_nodes.each do |child_node|
        str << print_in_order(child_node)
      end
      return str
    end
  end

  private

  def convert_fullname_to_id name
    name.split('_')[1]
  end
end
