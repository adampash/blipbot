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
    excerpt = data["parsedBody"]["plaintext"]
    blog_name = get_blog_name data
    link = "[<a href=\"#{data["permalink"]}\">#{blog_name}</a>]"
    "<p>#{excerpt} #{link}</p>"
  end

  def self.get_blog_name(data)
    blog_id = data["defaultBlogId"]
    blog_name = ""
    data["blogs"].each do |blog|
      blog_name = blog["displayName"] if blog["id"] == blog_id
    end
    blog_name
  end

end
