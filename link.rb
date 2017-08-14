class Link
  attr_accessor :title
  attr_accessor :name #fullname
  attr_accessor :id
  attr_accessor :view_count
  attr_accessor :permalink
  attr_accessor :created
  attr_accessor :score
  attr_accessor :subreddit_id
  attr_accessor :num_comments

  def initialize args
    @title ||= args["title"]
    @name ||= args["name"]
    @id ||= args["id"]
    @view_count ||= args["view_count"]
    @permalink ||= args["permalink"]
    @created ||= args["created"]
    @score ||= args["score"]
    @subreddit_id ||= args["subreddit_id"]
    @num_comments ||= args["num_comments"]
  end
end
