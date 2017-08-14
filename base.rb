require 'base64'
require 'httparty'
require 'pry'
require 'json'

require_relative 'link'
require_relative 'comment'

class Base
  include HTTParty

  RAW_JSON = "raw_json=1".freeze
  CREDENTIALS_FILE = 'credentials.json'.freeze
  USER_AGENT = 'UneebTest/1.0 (Mac OSX)'.freeze

  def initialize
    @credentials = get_credentials_from_file 
    # acquire the token to talk to the authenticated API
    acquire_token
    # set the base URI to the authenticated site
    self.class.base_uri "https://oauth.reddit.com"
    @default_options = {
      headers: {
        "User-Agent" => USER_AGENT,
        "Authorization" => "Bearer " + @access_token
      }
    }
  end

  def get_request url, options
    options.merge!(@default_options)
    response = self.class.get(url, options)
    # converts the HTTParty response to a hash
    response.parsed_response
  end

  def get_subreddit_hot subreddit, count=0
    opts = {query: {"count" => count.to_s}}
    url = "/r/#{subreddit}/hot"
    get_request url, opts
  end

  def all_news_today
    url = "/r/worldnews/top"
    all_news = get_listing_children url, nil, []
    all_news
  end

  def comment_tree id, depth=nil, limit=nil, sort="top"
    url = "/r/worldnews/comments/#{id}"
    comment = nil
    showmore = false
    opts = {query: {
      "comment" => comment, 
      "depth" => depth, 
      "sort" => sort, 
      "showmore" => showmore,
      "limit" => limit
    }}
    get_request url, opts
  end

  # @return [Comment]
  def get_all_comments id, limit=nil
    response = comment_tree(id, 1, limit)
    root_comments = response[1]
    if root_comments["kind"] == "Listing"
      data = root_comments["data"]
      before = data["before"]
      after = data["after"]
      children = data["children"]
      comments = []
      children.each do |child|
        child_data = child["data"]
        comments << Comment.new(child_data)
      end
      return comments
    else
      raise "Expected a Listing"
    end
  end

  def morechildren
    url = "/api/morechildren"
    api_type = nil 
    children = nil
    id = nil
    link_id = nil
    sort = nil
    opts = {query: {"api_type" => api_type, "children" => children, "id" => id, "link_id" => link_id, "sort" => sort}}
    get_request url, opts
  end

  # TODO pass a block here to execute a method on data
  def get_listing_children url, after, all_links
    opts = {query: {"t" => "day", "count" => "25", "after" => after}}
    response = get_request url, opts
    if response["kind"] == "Listing"
      data = response["data"]
      before = data["before"]
      after = data["after"]
      children = data["children"]
      if children.length == 25
        last_loop = false
      else
        last_loop = true
      end
      children.each do |child|
        if child["kind"] == "t3"
          link = Link.new(child["data"])
          all_links << link 
        else
          raise "Expected a link"
        end
      end
      if last_loop
        return all_links
      else
        get_listing_children url, after, all_links
      end
    else
      raise "Expected a listing"
    end 
  end
  
  def print_top_ten_news_today
    allnews = get_subreddit_hot "worldnews", 10
    allnews["data"]["children"].each do |news|
      puts news["data"]["title"]
    end
  end

  def get_myself
    self.class.get("/api/v1/me", @default_options)
  end

  def get_all_top_listings
    opts = {query: {"t" => "day", "limit" => "1"}}
    response = get_request "/r/the_Donald/top", opts
    response = response.parsed_response
    all_articles = response["data"]["children"]
    all_articles.each do |article|
      kind = article["kind"]
      id = article["data"]["id"]
      full_id = article["data"]["name"]
      title = article["data"]["title"]
      puts full_id
      puts title
      options = @default_options.merge(
        {query: {
          "article" => id,
          "context" => "8",
          "showedits" => "false",
          "showmore" => "true",
          "sort" => "top",
          "threaded" => "false",
          "truncate" => "10"
        }}
      )
      response_comments = self.class.get("/r/the_Donald/comments/article", options).parsed_response
      all_comments = response_comments[1]["data"]["children"]
      all_comments.each do |comment|
        puts "---------------COMMENT"
        puts comment["data"]["body"]
        puts "------------ENDCOMMENT"
      end
    end
  end

  private

  def acquire_token
    self.class.base_uri "https://www.reddit.com"
    encoding = Base64.encode64("#{@credentials['client_id']}:#{@credentials['client_secret']}")
    auth_options = {
      body: {
        "grant_type" => "password",
        "username" => @credentials["username"],
        "password" => @credentials["password"]
      },
      headers: {
        "User-Agent" => USER_AGENT,
        "Content-Type" => "application/x-www-form-urlencoded",
        "Authorization" => "Basic " + encoding
      }
    }
    @access_token = get_token(auth_options)
  end

  def get_token(options)
    response = self.class.post('/api/v1/access_token', options)
    response["access_token"]
  end

  def get_credentials_from_file
    JSON.parse(File.read(CREDENTIALS_FILE))
  end

end
