require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

describe "rss feed" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  
  before(:all) do
    @post = TestDataHelper.valid_post
    @post1 = TestDataHelper.valid_post1
    @post2 = TestDataHelper.valid_post2
  end
  
  it "should return the correct response" do
    get '/rss.xml'
    last_response.should be_ok
  end
  
  it "should contain the blog details" do
    get '/rss.xml'
    
    last_response.body.should include(Blog.url)
    last_response.body.should include(Blog.site_name)
    last_response.body.should include(Blog.site_description)
    
    last_response.body.should include(@post.title)
    last_response.body.should include(@post1.title)
    last_response.body.should include(@post2.title)
  end

end
