require_relative '../../lib/post_client'

describe PostClient do
  it 'does not trim short sentences' do
    sentence = "He's responsible for the likes of 1983's Videodrome, 1986's The Fly remake, 1988's Dead Ringers, and 2005's A History of Violence, but David Cronenberg may have delivered his most disturbing movie with Maps to the Stars."
    result = "\"He's responsible for the likes of 1983's Videodrome, 1986's The Fly remake, 1988's Dead Ringers, and 2005's A History of Violence, but David Cronenberg may have delivered his most disturbing movie with Maps to the Stars.\""
    excerpt = PostClient.shrink(sentence)
    expect(excerpt).to eq result
  end

  it 'trims long pieces of text to fp excerpts' do
    long_sentence = "He's responsible for the likes of 1983's Videodrome, 1986's The Fly remake, 1988's Dead Ringers, and 2005's A History of Violence, but David Cronenberg may have delivered his most disturbing movie with Maps to the Stars. It's a tale of celebrity aspiration and Hollywood misery that weaves together incest, mental illness, a dead kid or two, a burn victim (played by Mia Wasikowska), a washed-up actress gunning for another hit who resembles what Lindsay Lohan might be like in 15 years (Julianne Moore as Havana Segrand), and a Bieber-esque child star who's already been to rehab (Evan Bird as Benjie Weiss). It's full of desperation, violence, and excruciatingly grim humor. There are images in this movie that are as indelible as they are hard to look at."
    excerpt = PostClient.shrink(long_sentence)
    expect(excerpt.length).to be < 300
    expect(excerpt[-4..-2]).to eq '...'
  end

  it 'does not use an ellipsis if last word ends with . or ! or ?' do
    long_sentence = "He's responsible for the likes of 1983's Videodrome, 1986's The Fly remake, 1988's Dead Ringers, and 2005's A History of Violence, but David Cronenberg may have delivered his most disturbing movie with Maps to the Stars. It's a tale of celebrity aspiration and Hollywood misery! That weaves together incest, mental illness, a dead kid or two, a burn victim (played by Mia Wasikowska), a washed-up actress gunning for another hit who resembles what Lindsay Lohan might be like in 15 years (Julianne Moore as Havana Segrand), and a Bieber-esque child star who's already been to rehab (Evan Bird as Benjie Weiss). It's full of desperation, violence, and excruciatingly grim humor. There are images in this movie that are as indelible as they are hard to look at."
    excerpt = PostClient.shrink(long_sentence)
    expect(excerpt[-4..-2]).to_not eq '...'
  end

  it "converts quotes in text to single quotes" do
    sentence = 'And then he said, "Oh wow, that is interesting."'
    expected = "\"And then he said, 'Oh wow, that is interesting.'\""
    excerpt = PostClient.shrink(sentence)
    expect(excerpt).to eq expected
  end

  it "makes a body with a headline" do
    json = {
      "data" => {
        "headline" => "Foo",
        "defaultBlogId" => 1,
        "sharingMainImage" => { "src" => "http://example.com/image.png" },
        "permalink" => "http://example.com/2312321",
        "blogs" => [{"id" => 1, "displayName" => "io9"}]
      }
    }
    sentence = 'And then he said, "Oh wow, that is interesting."'
    expected = "\"And then he said, 'Oh wow, that is interesting.'\""
    excerpt = PostClient.body_with_headline(json)
    expect(excerpt).to eq "<p><a href=\"http://example.com/2312321\"><img src=\"http://example.com/image.png\" /></a></p><p><a href=\"http://example.com/2312321\">Foo</a> [io9]</p>"

  end

  it "doesn't include an image if there isn't one" do
    json = {
      "data" => {
        "headline" => "Foo",
        "defaultBlogId" => 1,
        "sharingMainImage" => { "src" => "" },
        "permalink" => "http://example.com/2312321",
        "blogs" => [{"id" => 1, "displayName" => "io9"}]
      }
    }
    sentence = 'And then he said, "Oh wow, that is interesting."'
    expected = "\"And then he said, 'Oh wow, that is interesting.'\""
    excerpt = PostClient.body_with_headline(json)
    expect(excerpt).to eq "<p><a href=\"http://example.com/2312321\">Foo</a> [io9]</p>"

  end

  it "extracts the root domain of the post" do
    json = {
      "data" => {
        "headline" => "Foo",
        "defaultBlogId" => 1,
        "sharingMainImage" => { "src" => "" },
        "permalink" => "http://gawker.com/2312321",
        "blogs" => [{"id" => 1, "displayName" => "io9"}]
      }
    }
    expect(PostClient.get_channel(json)).to eq "gawker"
    json["data"]["permalink"] = "http://dog.gawker.com/23412324"

    expect(PostClient.get_channel(json)).to eq "gawker"
  end
end
