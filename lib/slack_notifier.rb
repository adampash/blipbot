SLACK_TOKEN = ENV["SLACK_TOKEN"]
SLACK_WEBHOOK = ENV["SLACK_WEBHOOK"]

module SlackNotifier
  def self.notify(message, channel="#editlead")
    notifier = Slack::Notifier.new SLACK_WEBHOOK

    notifier.ping message,
      icon_emoji: ":chart_with_upwards_trend:",
      channel: channel,
      username: "SpikeBot"
  end
end
