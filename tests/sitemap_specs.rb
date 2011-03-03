require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

describe "sitemap" do
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
    get '/sitemap.xml'
    last_response.should be_ok
  end

  it "should contain the post and page details" do
    get '/sitemap.xml'

    last_response.body.should include(@post.permalink)
    last_response.body.should include(@post.url_date)
    
    last_response.body.should include(@post1.permalink)
    last_response.body.should include(@post1.url_date)
    
    last_response.body.should include(@post2.permalink)
    last_response.body.should include(@post2.url_date)
  end

end
