require File.dirname(__FILE__) + '/../app/shout_mouth.rb'
require 'rspec'
require 'rack/test'

describe "archive based layout pages" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  
  before(:all) do
    #arrange
    user = User.new(:email => "test@rails.com", :password => "password@1", :firstname => "Test", :lastname => "Rails")
    user.save
    
    @post = Post.new(:title => "ARCHIVE POST1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :user => user)
    @post.save
    
    @post1 = Post.new(:title => "ARCHIVE POST2", :body => "bd1", :tags => "tag3, tag4", :categories => "category3, category4", :user => user)
    @post1.save
  end
  
  it "should return the correct response when the archive url is called" do
    get '/archive'
    last_response.should be_ok
  end
  
  it "should contain the correct post details when the archive url is called" do
    get '/archive'
    last_response.body.should include(@post.title)
    last_response.body.should include(@post1.title)
  end
  
  #Given the tags and categories will use the same layout as the archive page i will use the same spec class for tests
  it "should return the correct response when the tag/tag1 url is called" do
    get '/tag/tag1'
    last_response.should be_ok
  end
  
  it "should contain the correct post details when the tag/tag1 url is called" do
    get '/tag/tag1'
    last_response.body.should include(@post.title)
    last_response.body.should_not include(@post1.title)
  end
  
  it "should return the correct response when the category/category1 url is called" do
    get '/category/category1'
    last_response.should be_ok
  end
  
  it "should contain the correct post details when the category/category1url is called" do
    get '/category/category1'
    last_response.body.should include(@post.title)
    last_response.body.should_not include(@post1.title)
  end
  

  
  
  
end