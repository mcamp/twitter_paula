class TwitterUser
  include MongoMapper::Document


  key :uid
  key :nick
  key :name
  key :friends_count
  key :followers_count
  key :protected_account
  key :tweets_count
  key :verified
  key :favorites_count
  key :profile_image_url
  key :url

  many :tweet_entities, order: :created_at

  scope :parisi, where(nick: "Fr_parisi")
  scope :claude, where(nick: "marcelclaude")
  scope :marco, where(nick: "marcoporchile")
  scope :holt, where(nick: "tjholt")
  scope :bachelet, where(nick: "ComandoMichelle")
  scope :roxana, where(nick: "RoxanaEsPueblo")
  scope :sfeir, where(nick: "Sfeir2014")
  scope :evelyn2014, where(nick: "Evelyn_2014")
  scope :matthei, where(nick: "evelynmatthei")
  scope :israel, where(nick: "ISRAELPRESIDENT")

  timestamps!

  def self.find_or_create_with_tweet tweet_user
    u = self.find_by_uid tweet_user.id.to_s
    unless u
      u = self.new
      u.uid = tweet_user.id.to_s
      u.nick = tweet_user.screen_name
      u.name = tweet_user.name
      u.friends_count = tweet_user.friends_count
      u.followers_count = tweet_user.followers_count
      u.protected_account = tweet_user.protected
      u.tweets_count = tweet_user.tweets_count
      u.verified = tweet_user.verified
      u.favorites_count = tweet_user.favorites_count
      u.profile_image_url = tweet_user.profile_image_uri.to_s
      u.url = tweet_user.uri.to_s
      u.created_at = tweet_user.created_at

      u.save
    end
    return u
  end

  def export_tweets_file
    File.open("data/#{nick}.csv", 'w'){ |file|
      file.puts TweetEntity.to_string_header
      self.tweet_entities.from_sample.to_sample.all.each{ |tweet|
        file.puts tweet.to_string_file
      }
    }
  end

end