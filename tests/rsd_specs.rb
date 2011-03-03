require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

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
    last_response.body.should include("https://github.com/dotnetguyuk/Shout-Mouth")
    last_response.body.should include("Shout Mouth")
    
    last_response.body.should include("MetaWeblog") 
  end

end