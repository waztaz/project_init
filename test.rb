require 'base64'
require 'httparty'
require 'pry'
require 'json'

class Basecamp
  include HTTParty

  RAW_JSON = "raw_json=1".freeze

  def initialize
    credentials = JSON.parse(File.read('credentials.json'))
    self.class.base_uri "https://www.reddit.com"
    encoding = Base64.encode64("#{credentials['client_id']}:#{credentials['client_secret']}")
    user_agent = 'UneebTest/1.0 (Mac OSX)'
    auth_options = {
      body: {
        "grant_type" => "password",
        "username" => credentials["username"],
        "password" => credentials["password"]
      },
      headers: {
        "User-Agent" => user_agent,
        "Content-Type" => "application/x-www-form-urlencoded",
        "Authorization" => "Basic " + encoding
      }
    }
    get_token(auth_options)

    self.class.base_uri "https://oauth.reddit.com"
    @options = {
      headers: {
        "User-Agent" => user_agent,
        "Authorization" => "Bearer " + @access_token
      }
    }
  end

  def get_myself
    self.class.get("/api/v1/me", @options)
  end

  def get_all_top_listings
    options = @options.merge({query: {"t" => "day", "limit" => "1"}})
    response = self.class.get("/r/the_Donald/top", options).parsed_response
    all_articles = response["data"]["children"]
    all_articles.each do |article|
      kind = article["kind"]
      id = article["data"]["id"]
      full_id = article["data"]["name"]
      title = article["data"]["title"]
      puts full_id
      puts title
      options = @options.merge(
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

  def get_subreddit_hot subreddit, count
    options = @options.merge({query: {"count" => count.to_s}})
    response = self.class.get("/r/#{subreddit}/hot", options).parsed_response
  end

  def get_token(options)
    response = self.class.post('/api/v1/access_token', options)
    @access_token = response["access_token"]
  end

end

allnews = Basecamp.new.get_subreddit_hot "worldnews", 10
allnews["data"]["children"].each do |news|
  puts news["data"]["title"]
end
