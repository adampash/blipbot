SLACK_TOKEN = ENV["SLACK_TOKEN"]
SLACK_WEBHOOK = ENV["SLACK_WEBHOOK"]

module SlackNotifier
  def self.notify(message, channel="#labs-test")
    notifier = Slack::Notifier.new SLACK_WEBHOOK

    notifier.ping message,
      icon_emoji: ":telescope:",
      channel: channel,
      username: "SpikeBot"
  end
end
