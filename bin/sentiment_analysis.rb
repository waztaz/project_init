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

start = Time.now
all_comments = construct_structure 'worldnews'
overall_sentiment = 0
all_comments.each do |comment|
  # extrapolate results
  sentiment = (comment.sentiment - 0.5) * 2
  sentiment_aggregated = sentiment * comment.score
  overall_sentiment += sentiment_aggregated
end
overall_sentiment = overall_sentiment / all_comments.length
overall_sentiment = overall_sentiment.round(2)
puts "Overall sentiment today: #{overall_sentiment}".green
execution_time = Time.now - start
puts "Overall execution time: #{execution_time.round} seconds".yellow
