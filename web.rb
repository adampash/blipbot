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
    SlackNotifier.notify "Umm slow down there, that last spike is missing a related widget. Are we gonna have a problem here?", "editlead", ":cop:", "CopBot"
    SlackNotifier.notify "Whoa, slow down there. Your latest spiking post is missing a related widget. We can fix it here, or we can fix it downtown. Your call. #{url}", PostClient.get_channel(json), ":cop:", "CopBot"
  end
  if PostClient.has_shutterstock(post_json)
    SlackNotifier.notify "Hey there, how're you doing? I'm a little worried about the stock photos I'm seeing here. Are you sure that's the best photo for this post? Need to talk it out?", "editlead", ":camera:", "ShutterBot"
  end
  status 200
  content_type :json
  response.to_json
end
