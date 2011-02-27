require File.dirname(__FILE__) + '/../app/shout_mouth.rb'
require 'rspec'
require 'rack/test'

describe "sitemap" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  
  it "should return the correct response" do
    get '/sitemap.xml'
    last_response.should be_ok
  end
  
  it "should contain the post and page details" do
    get '/sitemap.xml'
    
    last_response.body.should include(Post.first.permalink)
    last_response.body.should include(Post.first.url_date)
    
    last_response.body.should include(Post.first.permalink)
    last_response.body.should include(Post.first.url_date)
    
  end

end