# Basic sentiment analysis

# All takes into account comments, link are ignored.
# Upvotes and downvotes on links signify interest, but
# actual sentiments

# Comments can have reply. Each reply can either be in affirmative to the
# parent comment or a negation. Each comment substructure should represent
# a sentiment of a group as a whole. However it gets complicated in computing
# sentiments over groups. For this reason, we only compute sentiment
# for each individual commenter; reflecting his views and treated number of 
# upvotes as the number of individuals agreeing with it

# Sentiment of a comment = sentiment of the statement * comment score

require 'sentiment'
require 'colorize'
require 'mongo'

DATABASE_URL = ENV['DB_SENTIMENTS'] || 'mongodb://127.0.0.1:27017/test'

def get_sentiment
  all_comments = construct_structure
  overall_sentiment = 0
  all_comments.each do |comment|
    # extrapolate results
    sentiment = (comment.sentiment - 0.5) * 2
    sentiment_aggregated = sentiment * comment.score
    overall_sentiment += sentiment_aggregated
  end
  overall_sentiment = overall_sentiment / all_comments.length
  overall_sentiment.round(2)
end

def store_result
  db_client = Mongo::Client.new(DATABASE_URL)
  sentiments_collection = db_client[:sentiment2]
  sentiment = get_sentiment
  sentiments_collection.insert_one({ overall_sentiment: sentiment, time: Time.now.to_i })
end

loop do
  store_result
  sleep(60*30)
end
