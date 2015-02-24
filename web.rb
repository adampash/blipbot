require 'sinatra'
require 'kinja'

client = Kinja::Client.new(
  user: ENV["KINJA_USER"],
  password: ENV["KINJA_PASSWORD"]
)

post '/:id' do
  client.post(
    headline: 'foo',
    body: 'bar'
  )
end
