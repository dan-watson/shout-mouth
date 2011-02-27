require File.dirname(__FILE__) + '/../app/shout_mouth.rb'
require 'rspec'
require 'rack/test'

describe "rsd information" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  
  it "should return the correct response" do
    get '/rsd.xml'
    last_response.should be_ok
  end
  
  it "should contain the blog details" do
    get '/rsd.xml'
    
    last_response.body.should include(Blog.url)    
  end

end