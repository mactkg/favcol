require 'uri'
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

def debug_tw_ary(ary)
  ary.each do |fav|
    puts "#{fav.text} by #{fav.user.name}(@#{fav.user.screen_name})"
  end
end

def have_worth_url?(fav)
  fav.attrs[:entities][:urls].size > 0 &&
    fav.attrs[:entities][:urls].reject { |u| /https?:\/\/twitter.com/.match? u[:expanded_url] }.size > 0
end

screen_name = ARGV[0]

tweets_url_have = []
latest_favorite_id = nil
5.times do
  args = {
    screen_name: screen_name,
    count: 100,
    include_entities: true,
    max_id: latest_favorite_id
  }.compact
  favs = client.favorites(**args)
  tweets_url_have.concat(favs.select { |f| have_worth_url?(f) })
  latest_favorite_id = favs.last.id
end

tweets_url_have.each do |fav|
  puts "=== === ==="
  puts "🐣 #{fav.text} by #{fav.user.name}(@#{fav.user.screen_name})"
  puts "🌏 #{fav.attrs[:entities][:urls].map{ |u| u[:expanded_url] }.join(" ") }"
end
