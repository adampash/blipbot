SLACK_TOKEN = ENV["SLACK_TOKEN"]
SLACK_WEBHOOK = ENV["SLACK_WEBHOOK"]

module SlackNotifier
  def self.notify(message, channel="editlead", emoji=":chart_with_upwards_trend:", user="SpikeBot")
    notifier = Slack::Notifier.new SLACK_WEBHOOK, {"unfurl_links": false}

    notifier.ping message,
      icon_emoji: emoji,
      channel: channel,
      username: user
  end
end
