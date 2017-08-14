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
      x = @client.get_all_comments id, 10
      x.each do |comment|
        comment_opts = {
          "fullname" => comment.name, 
          "score" => comment.score,
          "children_nodes" => []
        }
        comment_node = Node.new(comment_opts)
        child_link_node.append_child(comment_node)
      end
    end
    @root
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
