require 'httparty'

class PostClient
  KINJA_POST_API = "https://kinja-api.herokuapp.com/post"

  def self.is_post?(link)
    !get_post_id(link).nil?
  end

  def self.get_post_json(link)
    id = get_post_id(link)
    JSON.parse HTTParty.get "#{KINJA_POST_API}/#{id}"
  end

  def self.get_post_id(link)
    if link.match(/\/(\d+)\//)
      link.match(/\/(\d+)\//)[1]
    elsif link.match(/-(\d+)[\/\b\+#]?/)
      link.scan(/-(\d+)[\/\b\+#]?/).last.last
    end
  end

  def self.format_body(json)
    data = json["data"]
    excerpt = data["plaintext"]
    blog_name = get_blog_name data
    link = "[<a x-inset=\"1\" href=\"#{data["permalink"]}\">#{blog_name}</a>]"
    "<p>#{shrink excerpt} #{link}</p>"
  end

  def self.body_with_headline(json)
    data = json["data"]
    headline = data["headline"]
    img = data["sharingMainImage"]["src"]
    blog_name = get_blog_name data
    link = data["permalink"]
    "#{img.nil? or img == "" ? "" : "<p><a href=\"#{link}\"><img src=\"#{img}\" /></a></p>"}<p><a href=\"#{link}\">#{headline}</a> [#{blog_name}]</p>"
  end

  def self.shrink(text)
    while text.length > 280
      text = text.split(' ')[0...-1].join(' ')
    end
    unless text[-1].match(/[\.!\?'"]/)
      if text[-1].match(/::punct::/)
        text = text[0...-1]
      end
      text += "..."
    end
    text.gsub!('"', "'")
    "\"#{text}\""
  end

  def self.get_blog_name(data)
    blog_id = data["defaultBlogId"]
    blog_name = ""
    data["blogs"].each do |blog|
      blog_name = blog["displayName"] if blog["id"] == blog_id
    end
    blog_name
  end

  def self.has_related_widget(post_json)
    text = post_json["data"]["original"]
    text.include?('gawker-labs.com/related-widget')
  end

  def self.has_shutterstock(post_json)
    text = post_json["data"]["original"]
    !(text =~ /shutterstock/i).nil?
  end

  def self.get_channel(post_json)
    permalink = post_json["data"]["permalink"]
    regex = /https?:\/\/(\w*\.)?(\w*)\.com/
    permalink.match(regex)[2]
  end

end
