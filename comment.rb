class Comment
  attr_accessor :id
  attr_accessor :name
  attr_accessor :parent_id
  attr_accessor :link_id #fullname of the link
  attr_accessor :subreddit_id
  attr_accessor :score
  attr_accessor :author
  attr_accessor :created
  attr_accessor :body
  attr_accessor :depth

  def initialize args
    @id ||= args["id"]
    @name ||= args["name"]
    @parent_id ||= args["parent_id"]
    @link_id ||= args["link_id"]
    @subreddit_id ||= args["subreddit_id"]
    @score ||= args["score"]
    @author ||= args["author"]
    @created ||= args["created"]
    @body ||= args["body"]
    @depth ||= args["depth"]
  end
end
