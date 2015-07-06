#!/usr/bin/ruby

# Make sure you have these gems installed
require 'rubygems'
require 'thread'
require 'csv'
require 'parseconfig'
require 'twitter'
require 'marky_markov'

# Create a new Twitter account that you'd like to have your auto-tweets posted to
# Go to dev.twitter.com, create a new application with Read+Write permissions
# Create an access token + secret for the account and copy that and the consumer key and secrets into config.txt
PATH_TO_TWEETS_CSV   = 'tweets.csv'
PATH_TO_TWEETS_CLEAN = 'markov_dict.txt'

config = ParseConfig.new('config.txt')
ACCESS_TOKEN =  config['ACCESS_TOKEN'] || abort('Can\'t post to Twitter without ACCESS_TOKEN in config.txt')
ACCESS_TOKEN_SECRET =  config['ACCESS_TOKEN_SECRET'] || abort('Can\'t post to Twitter without ACCESS_TOKEN_SECRET in config.txt')
CONSUMER_KEY =  config['CONSUMER_KEY'] || abort('Can\'t post to Twitter without CONSUMER_KEY in config.txt')
CONSUMER_SECRET =  config['CONSUMER_SECRET'] || abort('Can\'t post to Twitter without CONSUMER_SECRET in config.txt')


### -----------------------------------------------------------------------------------------------------

# Go to Twitter.com -> Settings -> Download Archive. 
# This tweets.csv file is in the top directory. Put it in the same directory as this script.
csv_text = CSV.parse(File.read(PATH_TO_TWEETS_CSV).encode!("UTF-8", "iso-8859-1", invalid: :replace))

# Create a new clean file of text that acts as the seed for your Markov chains
File.open(PATH_TO_TWEETS_CLEAN, 'w') do |file|
  csv_text.reverse.each do |row|
    # Strip links and new lines
    tweet_text = row[5].gsub(/(?:f|ht)tps?:\/[^\s]+/, '').gsub(/\n/,' ')
 
 	# Strip #sorrynotsorry
    tweet_text = tweet_text.gsub(/#[Ss]orry[Nn]ot[Ss]orry/, '')

    # Strip leading RT
    tweet_text = tweet_text.gsub(/^RT\s+/, '')

    # Save the text
    file.write("#{tweet_text}\n")
  end
end
  
# Run when you want to generate a new Markov tweet
markov = MarkyMarkov::Dictionary.new('dictionary') # Saves/opens dictionary.mmd
markov.parse_file PATH_TO_TWEETS_CLEAN
tweet_text = markov.generate_n_sentences(2).split(/\#\</).first.chomp.chop
markov.save_dictionary!
    
# Connect to your Twitter account
# Twitter.configure do |config|
#   config.consumer_key    = CONSUMER_KEY
#   config.consumer_secret = CONSUMER_SECRET
# end
# twitter_client = Twitter::Client.new(:oauth_token => ACCESS_TOKEN,
#                               :oauth_token_secret => ACCESS_TOKEN_SECRET)
# p "#{Time.now}: #{tweet_text}"
# twitter_client.update(tweet_text)

puts(tweet_text)