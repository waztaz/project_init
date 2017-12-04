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

all_comments = construct_structure
all_comments.each do |each_comment|
  puts "#{each_comment.score}: #{each_comment.body}"
end
