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
    status: "PUBLISHED"
  )
  puts post
  if post["data"].nil?
    response = { url: "Problem creating blip. Probabaly Kinja API issue." }
  else
    response = { url: post["data"]["permalink"] }
  end
  SlackNotifier.notify "Please consider splicing if it makes sense for your site. All will benefit.\n\nOriginal: #{url}\nBlip: #{response[:url]}"
  unless PostClient.has_related_widget(post_json)
    SlackNotifier.notify "Umm uh oh guys, that last spike might be missing a related widget. Are we gonna have a problem here?", "editlead", ":cop:", "CopBot"
  end
  status 200
  content_type :json
  response.to_json
end
