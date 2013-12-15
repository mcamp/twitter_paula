TW = YAML::load(File.open("#{Rails.root}/config/twitter.yml"))
TWITTER_CLIENT = Twitter::REST::Client.new do |config|
  config.consumer_key        = TW["consumer"]
  config.consumer_secret     = TW["secret"]
  config.access_token        = TW["token"]
  config.access_token_secret = TW["token_secret"]
end