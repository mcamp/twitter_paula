module TwitterCollect

  def self.collect_with_nick_name nick_name
    puts ">>COLLECTION: #{nick_name}"
    query_count  = 200
    count_tweets = 0
    puts ">>QUERYING TWEETS - #{count_tweets}"
    tweets = TWITTER_CLIENT.user_timeline(nick_name, count: query_count, include_rts: false, :include_entities => true)
    count_tweets = query_count + count_tweets
    save_tweets tweets
    last = tweets.last

    while !last.nil?
      puts ">>QUERYING TWEETS - #{count_tweets}"
      tweets = TWITTER_CLIENT.user_timeline(nick_name, count: query_count, include_rts: false, max_id: (last.id-1), :include_entities => true)
      count_tweets = query_count + count_tweets
      save_tweets tweets
      last = tweets.last
    end

  end

  def self.collect_all
    #"fr_parisi", "marcelclaude", "marcoporchile", "tjholt", "comandomichelle", "RoxanaEsPueblo", "sfeir2014","evelyn_2014", "evelynmatthei", "israelpresident"].each{|nick|
    ["evelynmatthei"].each{|nick|
      collect_with_nick_name nick
    }
  end

  def self.save_tweets tweets
    puts ">>>>SAVING #{tweets.count}"
    tweets.each{|tweet|
      user = TwitterUser.find_or_create_with_tweet tweet.user
      TweetEntity.create_with_tweet_and_user tweet, user
    }
  end

end
