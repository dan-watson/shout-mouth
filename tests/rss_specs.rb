require File.dirname(__FILE__) + '/../app/shout_mouth.rb'
require 'rspec'
require 'rack/test'

describe "rss feed" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  
  it "should return the correct response" do
    get '/rss'
    last_response.should be_ok
  end
  
  it "should contain the blog details" do
    get '/rss'
    
    last_response.body.should include(Blog.url)
    last_response.body.should include(Blog.site_name)
    last_response.body.should include(Blog.site_description)
    
    last_response.body.should include(Post.first.title)
    
  end

end