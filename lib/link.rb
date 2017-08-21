class Link
  attr_reader :title
  attr_reader :name #fullname
  attr_reader :id
  attr_reader :view_count
  attr_reader :permalink
  attr_reader :created
  attr_reader :score
  attr_reader :subreddit_id
  attr_reader :num_comments
  attr_reader :slug

  def initialize args
    @title ||= args["title"]
    @name ||= args["name"]
    @id ||= args["id"]
    @view_count ||= args["view_count"]
    @permalink ||= args["permalink"]
    @slug = fetch_the_slug if @permalink
    @created ||= args["created"]
    @score ||= args["score"]
    @subreddit_id ||= args["subreddit_id"]
    @num_comments ||= args["num_comments"]
  end

  private

  # get the last value in the url
  def fetch_the_slug
    @permalink.split('/')[-1]
  end
end
