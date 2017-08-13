require_relative 'base'

allnews = Base.new.get_subreddit_hot "worldnews", 10
allnews["data"]["children"].each do |news|
  puts news["data"]["title"]
end
