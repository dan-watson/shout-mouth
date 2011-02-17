require File.dirname(__FILE__) + '/../shout_mouth.rb'
require File.dirname(__FILE__) + '/test_data/test_data.rb'

require 'rspec'
require 'rack/test'
require 'factory_girl'
require 'datamapper'
require 'nokogiri'

describe "metaweblog api" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  
  before(:all) do
    #Clean Database
    DataMapper.auto_migrate!
    
    #Test Data 
    @user = User.new(:email => "api@email.com", :password => "password111", :firstname => "Dan", :lastname => "Watson")
    @user.save
    @post = Factory(:valid_post)
    @post.user = @user
    @post.save
    
    #Code was executing too quickly not allowing atleast a second before saving next post
    #this caused the test to fail because we are looking for the posts to come back
    #in decending order based upon the created date.
    sleep(1.5)
    
    @second_post = Factory(:valid_post)
    @second_post.user = @user
    @second_post.save
  end
    
  it "should return correct response when the getUserInfo method is called" do
    post '/metaweblog',  "<methodCall> 
                          <methodName>blogger.getUserInfo</methodName>
                          <params>
                          <param><value><string>Blog Name</string></value></param>
                          <param><value><string>#{@user.email}</string></value></param>
                          <param><value><string>password111</string></value></param>
                          </params>
                          </methodCall>"

    find_value(last_response.body, "userid", ["member", "name", "value", "i4"]).should == @user.id.to_s
    find_value(last_response.body, "firstname", ["member", "name", "value", "string"]).should == "Dan"
    find_value(last_response.body, "lastname", ["member", "name", "value", "string"]).should == "Watson"
    find_value(last_response.body, "url", ["member", "name", "value", "string"]).should == "http://127.0.0.1:9393"
    find_value(last_response.body, "email", ["member", "name", "value", "string"]).should == "api@email.com"
    find_value(last_response.body, "nickname", ["member", "name", "value", "string"]).should == "Dan Watson"
  end
  
  it "should return correct response when the getUsersBlogs method is called" do
    post '/metaweblog',  "<methodCall>
                          <methodName>blogger.getUsersBlogs</methodName>
                          <params>
                          <param><value><string>Blog Name</string></value></param>
                          <param><value><string>@user.email</string></value></param>
                          <param><value><string>password111</string></value></param>
                          </params>
                          </methodCall>"
                      
    find_value(last_response.body, "url", ["member", "name", "value", "string"]).should == "http://127.0.0.1:9393"
    find_value(last_response.body, "blogid", ["member", "name", "value", "i4"]).should == "2000"
    find_value(last_response.body, "blogname", ["member", "name", "value", "string"]).should == "Test Site"
  end
  
  
  it "should return correct response when the getRecentPosts method is called" do
    post '/metaweblog',  "<methodCall> 
                          <methodName>metaWeblog.getRecentPosts</methodName>
                          <params>
                          <param><value><string>Blog Name</string></value></param>
                          <param><value><string>@user.email</string></value></param>
                          <param><value><string>password111</string></value></param>
                          <param><value><i4>2</i4></value></param>
                          </params>
                          </methodCall>"
    find_value(last_response.body, "postid", ["member", "name", "value", "i4"], 0).should == @second_post.id.to_s
    find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 0).should == @second_post.created_at_iso8601
    find_value(last_response.body, "title", ["member", "name", "value", "string"], 0).should == @second_post.title
    find_value(last_response.body, "description", ["member", "name", "value", "string"], 0).should == @second_post.body
    find_value(last_response.body, "link", ["member", "name", "value", "string"], 0).should == @second_post.permalink
    find_value(last_response.body, "wp_slug", ["member", "name", "value", "string"], 0).should == @second_post.slug
    find_value(last_response.body, "mt_excerpt", ["member", "name", "value", "string"], 0).should == ""
    find_value(last_response.body, "mt_allow_comments", ["member", "name", "value", "string"], 0).should == ""
    find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"], 0).should == "tag1,tag2"
    find_value(last_response.body, "publish", ["member", "name", "value", "boolean"], 0).should == "1"
    find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"], 0).should == "cat1"
    find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"], 0).should == "cat2"
    
    find_value(last_response.body, "postid", ["member", "name", "value", "i4"], 1).should == @post.id.to_s
    find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 1).should == @post.created_at_iso8601
    find_value(last_response.body, "title", ["member", "name", "value", "string"], 1).should == @post.title
    find_value(last_response.body, "description", ["member", "name", "value", "string"], 1).should == @post.body
    find_value(last_response.body, "link", ["member", "name", "value", "string"], 1).should == @post.permalink
    find_value(last_response.body, "wp_slug", ["member", "name", "value", "string"], 1).should == @post.slug
    find_value(last_response.body, "mt_excerpt", ["member", "name", "value", "string"], 1).should == ""
    find_value(last_response.body, "mt_allow_comments", ["member", "name", "value", "string"], 1).should == ""
    find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"], 1).should == "tag1,tag2"
    find_value(last_response.body, "publish", ["member", "name", "value", "boolean"], 1).should == "1"
    find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"], 1).should == "cat1"
    find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"], 1).should == "cat2"
    
  end
  
  it "should return correct response when the getPost method is called" do
    post '/metaweblog',  "<methodCall> 
                          <methodName>metaWeblog.getPost</methodName>
                          <params>
                          <param><value><string>#{@second_post.id.to_s}</string></value></param>
                          <param><value><string>@user.email</string></value></param>
                          <param><value><string>password111</string></value></param>
                          <param><value><i4>2</i4></value></param>
                          </params>
                          </methodCall>"
    find_value(last_response.body, "postid", ["member", "name", "value", "i4"]).should == @second_post.id.to_s
    find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"]).should == @second_post.created_at_iso8601
    find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == @second_post.title
    find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == @second_post.body
    find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == @second_post.permalink
    find_value(last_response.body, "wp_slug", ["member", "name", "value", "string"]).should == @second_post.slug
    find_value(last_response.body, "mt_excerpt", ["member", "name", "value", "string"]).should == ""
    find_value(last_response.body, "mt_allow_comments", ["member", "name", "value", "string"]).should == ""
    find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"]).should == "tag1,tag2"
    find_value(last_response.body, "publish", ["member", "name", "value", "boolean"]).should == "1"
    find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"]).should == "cat1"
    find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"]).should == "cat2"
  end
  
  it "should return correct response when the getCategories method is called" do
    post '/metaweblog',  "<methodCall>
                          <methodName>blogger.getCategories</methodName>
                          <params>
                          <param><value><string>Blog Name</string></value></param>
                          <param><value><string>@user.email</string></value></param>
                          <param><value><string>password111</string></value></param>
                          </params>
                          </methodCall>"
    find_value(last_response.body, "description", ["member", "name", "value", "string"], 0).should == "cat1"               
    find_value(last_response.body, "title", ["member", "name", "value", "string"], 0).should == "cat1"
    find_value(last_response.body, "description", ["member", "name", "value", "string"], 1).should == "cat2"               
    find_value(last_response.body, "title", ["member", "name", "value", "string"], 1).should == "cat2" 
  end
  
  
  private 
  def find_value(xml, find, hierarchy = [], nth = nil)
    return Nokogiri::XML(xml).xpath("//#{hierarchy[0]}/#{hierarchy[1]}[text()='#{find}']")[nth.nil? ? 0 : nth].parent.xpath("#{hierarchy[2]}/#{hierarchy[3]}").text
  end
  
end