require 'sinatra'
require 'kinja'
require 'json'
require_relative './lib/post_client'

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
  post = client.post(
    headline: '',
    body: PostClient.format_body(post_json)
  )
  status 200
  body ''
end
