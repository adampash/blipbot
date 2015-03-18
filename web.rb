require 'sinatra'
require 'kinja'
require 'json'
require 'slack-notifier'

require_relative './lib/post_client'
require_relative './lib/slack_notifier'

client = Kinja::Client.new(
  user: ENV["KINJA_USER"],
  password: ENV["KINJA_PASSWORD"]
)

post '/:id' do
  post = client.post(
    headline: 'foo',
    body: 'bar'
  )
  status 200
  body ''
end

post '/' do
  puts params
  url = params[:url]
  post_json = PostClient.get_post_json(url)
  post = client.create_post(
    headline: '',
    body: PostClient.format_body(post_json),
    # body: PostClient.body_with_headline(post_json),
    status: "PUBLISHED"
  )
  puts post
  response = { url: post["data"]["permalink"] }
  SlackNotifier.notify "Please consider splicing if it makes sense for your site. All will benefit.\n\nOriginal: #{url}\nBlip: #{response[:url]}"
  status 200
  content_type :json
  response.to_json
end
