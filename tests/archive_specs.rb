require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'


describe "archive based layout pages" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  
  before(:all) do
    #arrange
    @post_with_tag1_tag2_category1_category2 = TestDataHelper.valid_post1
    @post_with_tag3_tag4_category3_category4 = TestDataHelper.valid_post2
  end

  it "should return the correct response when the archive url is called" do
    get '/archive'
    last_response.should be_ok
  end
  
  it "should contain the correct post details when the archive url is called" do
    get '/archive'
    last_response.body.should include(@post_with_tag1_tag2_category1_category2.title)
    last_response.body.should include(@post_with_tag3_tag4_category3_category4.title)
  end
  
  #Given the tags and categories will use the same layout as the archive page i will use the same spec class for tests
  it "should return the correct response when the tag/tag1 url is called" do
    get '/tag/tag1'
    last_response.should be_ok
  end
  
  it "should contain the correct post details when the tag/tag1 url is called" do
    get '/tag/tag1'
    last_response.body.should include(@post_with_tag1_tag2_category1_category2.title)
    last_response.body.should_not include(@post_with_tag3_tag4_category3_category4.title)
  end
  
  it "should return the correct response when the category/category1 url is called" do
    get '/category/category1'
    last_response.should be_ok
  end
  
  it "should contain the correct post details when the category/category1url is called" do
    get '/category/category1'
    last_response.body.should include(@post_with_tag1_tag2_category1_category2.title)
    last_response.body.should_not include(@post_with_tag3_tag4_category3_category4.title)
  end
  

  
  
  
end