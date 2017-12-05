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
require 'aws-sdk'
require 'json'
require 'securerandom'

CREDENTIALS_FILE = 'aws.json'.freeze

def get_credentials_from_file
  JSON.parse(File.read(CREDENTIALS_FILE))
end

@credentials = get_credentials_from_file

Aws.config.update({
  region: "us-west-2",
  endpoint: "http://localhost:8000",
  credentials: Aws::Credentials.new(@credentials['akid'], @credentials['secret'])
})

@dynamodb = Aws::DynamoDB::Client.new

params = {
  table_name: "Sentiments3",
  key_schema: [
    {
      attribute_name: "created_on",
      key_type: "HASH"  #Partition key
    }
  ],
  attribute_definitions: [
    {
      attribute_name: "created_on",
      attribute_type: "N"
    }
  ],
  provisioned_throughput: {
    read_capacity_units: 1,
    write_capacity_units: 1
  }
}

begin
  result = @dynamodb.create_table(params)
  puts "Created table. Status: " +
    result.table_description.table_status;

rescue  Aws::DynamoDB::Errors::ServiceError => error
  puts "Unable to create table:"
  puts "#{error.message}"
end

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
  sentiment = get_sentiment
  params = {
    table_name: 'Sentiments2',
    item: { 
      sentiment: sentiment,
      created_on: Time.now.to_i
    }
  }
  begin
    result = @dynamodb.put_item(params)
  rescue  Aws::DynamoDB::Errors::ServiceError => error
    puts "#{error.message}"
    exit
  end
end

# Analyze sentiments every 10 minutes
loop do
  store_result
  sleep(60*10)
end
