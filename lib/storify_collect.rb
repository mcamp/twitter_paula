module StorifyCollect

  def self.collect_from_storify link, last_page
    page = last_page
    per_page = 100
    while page > 0
      storify = RestClient::Resource.new(
        "#{link}?per_page=#{per_page}&page=#{page}",
        :verify_ssl => OpenSSL::SSL::VERIFY_PEER
      )
      storify_data = JSON.parse(storify.get)
      storify_data["content"]["elements"].reverse.each{ |elem|
        uid = elem["permalink"].split("/").last
        tweet = TweetEntity.new
        tweet.from_storify = true
        tweet.uid = uid
        saved = tweet.save

        awesome_print "#{uid}: #{saved}"
        unless saved
          awesome_print tweet.errors
        end
      }

      page = page - 1
    end
  end

  def self.get_all_from_storify
    links =
      [
        {link: "https://api.storify.com/v1/stories/Tesisnerd/muestra-franco-parisi", last_page: 3},
        {link: "https://api.storify.com/v1/stories/Tesisnerd/muestra-marco-enriquez-ominami", last_page: 10}
      ]

    links.each{|link|
      collect_from_storify link[:link], link[:last_page]
    }
  end

end
