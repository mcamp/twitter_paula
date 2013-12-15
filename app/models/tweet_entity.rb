class TweetEntity
  include MongoMapper::Document

  key :uid, unique: true
  key :favorite_count
  key :retweet_count
  key :source
  key :text
  key :truncated
  key :full_text
  key :tweet_url
  key :image_url
  key :in_reply_to_tweet_uid
  key :in_reply_to_user_uid
  key :geo_x
  key :geo_y
  key :public_tweet_replied, default: true
  key :from_storify, default: false

  belongs_to :twitter_user
  belongs_to :replied_tweet, class_name: "TweetEntity"

  scope :from_sample, where(:created_at.gte => Time.new(2013, 11, 1))
  scope :to_sample, where(:created_at.lt => Time.new(2013, 11, 19))


  timestamps!


  def self.create_with_tweet_and_user tweet, twitter_user
    t = self.new
    t.uid = tweet.id.to_s
    t.favorite_count = tweet.favorite_count
    t.retweet_count = tweet.retweet_count
    t.source = tweet.source
    t.text = tweet.text
    t.truncated = tweet.truncated
    t.full_text = tweet.full_text
    t.tweet_url = tweet.uri.to_s
    t.image_url = tweet.media.first.media_uri.to_s if tweet.media.first
    t.in_reply_to_tweet_uid = tweet.in_reply_to_status_id.to_s if tweet.in_reply_to_status_id
    t.in_reply_to_user_uid = tweet.in_reply_to_user_id.to_s if tweet.in_reply_to_user_id
    t.geo_x = tweet.geo.coordinates.first unless tweet.geo.nil?
    t.geo_y = tweet.geo.coordinates.second unless tweet.geo.nil?
    t.created_at = tweet.created_at

    t.twitter_user = twitter_user
    t.save
    return t
  end

  def self.add_replied_tweets
    query = TweetEntity.order(:created_at).where(:in_reply_to_tweet_uid.ne => nil)
    puts "TWEETS WITH REPLY: #{query.count}"
    query.find_each{ |tweet_entity|
      puts ">>reply tweet: #{tweet_entity.uid}"
      puts ">>replied tweet: #{tweet_entity.in_reply_to_tweet_uid}"

      unless tweet_entity.replied_tweet
        puts ">>STARTING<<"
        begin
          if tweet_entity.public_tweet_replied
            tweet_entity_replied = TweetEntity.find_by_uid tweet_entity.in_reply_to_tweet_uid
            unless tweet_entity_replied

              tweet_reply = TWITTER_CLIENT.status tweet_entity.in_reply_to_tweet_uid
              user = TwitterUser.find_or_create_with_tweet tweet_reply.user
              tweet_entity_replied = self.create_with_tweet_and_user tweet_reply, user

            end
            tweet_entity.replied_tweet = tweet_entity_replied
            tweet_entity.save
          end
        rescue Twitter::Error::NotFound, Twitter::Error::Forbidden
          puts ">>NOT FOUND<<"
          tweet_entity.public_tweet_replied = false
          tweet_entity.save
        end
      end
    }
  end

  def self.get_all_tweets_from_storify
    TweetEntity.where(from_storify: true, text: nil).all.each{|tweet_entity|
      begin
        tweet_entity.update_info_from_twitter
      rescue Twitter::Error::NotFound, Twitter::Error::Forbidden
        puts ">>FORBIDDEN<<"
        tweet_entity.destroy
      end
    }
  end

  def update_info_from_twitter
    puts ">>UPDATING uid:#{self.uid}"
    tweet = TWITTER_CLIENT.status self.uid
    user = TwitterUser.find_or_create_with_tweet tweet.user

    if update_info_with_tweet tweet, user
      puts ">>>>SUCCESS"
    else
      puts ">>>>ERROR"
      awesome_print self.errors
    end

  end

  def update_info_with_tweet tweet, user
    self.favorite_count = tweet.favorite_count
    self.retweet_count = tweet.retweet_count
    self.source = tweet.source
    self.text = tweet.text
    self.truncated = tweet.truncated
    self.full_text = tweet.full_text
    self.tweet_url = tweet.uri.to_s
    self.image_url = tweet.media.first.media_uri.to_s if tweet.media.first
    self.in_reply_to_tweet_uid = tweet.in_reply_to_status_id.to_s if tweet.in_reply_to_status_id
    self.in_reply_to_user_uid = tweet.in_reply_to_user_id.to_s if tweet.in_reply_to_user_id
    self.geo_x = tweet.geo.coordinates.first unless tweet.geo.nil?
    self.geo_y = tweet.geo.coordinates.second unless tweet.geo.nil?
    self.created_at = tweet.created_at

    self.twitter_user = user
    self.save
  end

  def to_string_file
    "#{uid}|#{favorite_count}|#{retweet_count}|#{source}|#{truncated}|#{tweet_url}|#{image_url}|#{in_reply_to_tweet_uid}|#{in_reply_to_user_uid}|#{geo_x}|#{geo_y}|#{created_at}|#{created_at.to_i}"
  end

  def self.to_string_header
    "uid|favorite_count|retweet_count|source|truncated|tweet_url|image_url|in_reply_to_tweet_uid|in_reply_to_user_uid|geo_x|geo_y|created_at|created_timestamp"
  end

end