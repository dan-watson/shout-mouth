require File.dirname(__FILE__) + '/../app/shout_mouth.rb'
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
    post '/xmlrpc/',  "<methodCall> 
                          <methodName>blogger.getUserInfo</methodName>
                          <params>
                          <param><value><string>Blog Name</string></value></param>
                          <param><value><string>api@email.com</string></value></param>
                          <param><value><string>password111</string></value></param>
                          </params>
                          </methodCall>"

    find_value(last_response.body, "userid", ["member", "name", "value", "i4"]).should == @user.id.to_s
    find_value(last_response.body, "firstname", ["member", "name", "value", "string"]).should == "Dan"
    find_value(last_response.body, "lastname", ["member", "name", "value", "string"]).should == "Watson"
    find_value(last_response.body, "url", ["member", "name", "value", "string"]).should == "http://192.168.1.68:9393"
    find_value(last_response.body, "email", ["member", "name", "value", "string"]).should == "api@email.com"
    find_value(last_response.body, "nickname", ["member", "name", "value", "string"]).should == "Dan Watson"
  end
  
  it "should return correct response when the getUsersBlogs method is called" do
    post '/xmlrpc/',  "<methodCall>
                          <methodName>blogger.getUsersBlogs</methodName>
                          <params>
                          <param><value><string>Blog Name</string></value></param>
                          <param><value><string>api@email.com</string></value></param>
                          <param><value><string>password111</string></value></param>
                          </params>
                          </methodCall>"
                      
    find_value(last_response.body, "url", ["member", "name", "value", "string"]).should == "http://192.168.1.68:9393"
    find_value(last_response.body, "blogid", ["member", "name", "value", "i4"]).should == "2000"
    find_value(last_response.body, "blogName", ["member", "name", "value", "string"]).should == "Test Site"
  end
  
  
  it "should return correct response when the getRecentPosts method is called" do
    post '/xmlrpc/',  "<methodCall> 
                          <methodName>metaWeblog.getRecentPosts</methodName>
                          <params>
                          <param><value><string>Blog Name</string></value></param>
                          <param><value><string>api@email.com</string></value></param>
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
    post '/xmlrpc/',  "<methodCall> 
                          <methodName>metaWeblog.getPost</methodName>
                          <params>
                          <param><value><string>#{@second_post.id.to_s}</string></value></param>
                          <param><value><string>api@email.com</string></value></param>
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
    post '/xmlrpc/',  "<methodCall>
                          <methodName>blogger.getCategories</methodName>
                          <params>
                          <param><value><string>Blog Name</string></value></param>
                          <param><value><string>api@email.com</string></value></param>
                          <param><value><string>password111</string></value></param>
                          </params>
                          </methodCall>"
    find_value(last_response.body, "description", ["member", "name", "value", "string"], 0).should == "cat1"               
    find_value(last_response.body, "title", ["member", "name", "value", "string"], 0).should == "cat1"
    find_value(last_response.body, "description", ["member", "name", "value", "string"], 1).should == "cat2"               
    find_value(last_response.body, "title", ["member", "name", "value", "string"], 1).should == "cat2" 
  end
  
  it "should update the correct post and give the correct response when the editPost method is called" do
    
    post_to_update_id = Post.first.id
    
    post '/xmlrpc/',  "<methodCall>
     <methodName>metaWeblog.editPost</methodName>
     <params>
      <param>
       <value>
        <string>#{post_to_update_id}</string>
       </value>
      </param>
      <param>
       <value>
        <string>api@email.com</string>
       </value>
      </param>
      <param>
       <value>
        <string>password111</string>
       </value>
      </param>
      <param>
       <value>
        <struct>
         <member>
          <name>title</name>
          <value>
           <string>New Title</string>
          </value>
         </member>
         <member>
          <name>description</name>
          <value>
           <string>New Body</string>
          </value>
         </member>
         <member>
          <name>categories</name>
          <value>
           <array>
            <data>
             <value>
              <string>cat4</string>
             </value>
             <value>
              <string>cat5</string>
             </value>
            </data>
           </array>
          </value>
         </member>
         <member>
          <name>dateCreated</name>
          <value>
           <dateTime.iso8601>20110221T21:41:00</dateTime.iso8601>
          </value>
         </member>
         <member>
          <name>date_created_gmt</name>
          <value>
           <dateTime.iso8601>20110221T21:41:00</dateTime.iso8601>
          </value>
         </member>
        </struct>
       </value>
      </param>
      <param>
       <value>
        <boolean>1</boolean>
       </value>
      </param>
     </params>
    </methodCall>"
    
    post = Post.find(:id => post_to_update_id).first
    post.title.should == "New Title"
    post.body.should == "New Body"
    post.categories.should include("cat4", "cat5")
    
    find_value(last_response.body, "postid", ["member", "name", "value", "i4"]).should == post_to_update_id.to_s
    find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"]).should == post.created_at_iso8601
    find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == post.title
    find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == post.body
    find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == post.permalink
    find_value(last_response.body, "wp_slug", ["member", "name", "value", "string"]).should == post.slug
    find_value(last_response.body, "mt_excerpt", ["member", "name", "value", "string"]).should == ""
    find_value(last_response.body, "mt_allow_comments", ["member", "name", "value", "string"]).should == ""
    find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"]).should == "cat4,cat5"
    find_value(last_response.body, "publish", ["member", "name", "value", "boolean"]).should == "1"
    find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"]).should == "cat4"
    find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"]).should == "cat5"
    
  end
  
  
  it "should create a new post and give the correct response when the newPost method is called" do  
    post '/xmlrpc/',  "<methodCall>
     <methodName>metaWeblog.newPost</methodName>
     <params>
      <param>
       <value>
        <string>2000</string>
       </value>
      </param>
      <param>
       <value>
        <string>api@email.com</string>
       </value>
      </param>
      <param>
       <value>
        <string>password111</string>
       </value>
      </param>
      <param>
       <value>
        <struct>
         <member>
          <name>title</name>
          <value>
           <string>New Post From Metaweblog Client</string>
          </value>
         </member>
         <member>
          <name>description</name>
          <value>
           <string>&lt;p&gt;Some Body&lt;/p&gt;</string>
          </value>
         </member>
         <member>
          <name>categories</name>
          <value>
           <array>
            <data>
             <value>
              <string>cat1</string>
             </value>
             <value>
              <string>cat2</string>
             </value>
             <value>
              <string>cat4</string>
             </value>
            </data>
           </array>
          </value>
         </member>
        </struct>
       </value>
      </param>
      <param>
       <value>
        <boolean>1</boolean>
       </value>
      </param>
     </params>
    </methodCall>"
    
    post = Post.first(:title => "New Post From Metaweblog Client")
    post.title.should == "New Post From Metaweblog Client"
    post.body.should == "<p>Some Body</p>"
    post.categories.should include("cat1", "cat2", "cat4")
    post.is_active.should be_true
    
    last_response.body.should include("<i4>#{post.id}</i4>")
  end
  
  it "should mark a post as not published and give the correct response when the deletePost method is called" do  
    
    post_to_delete = Factory(:valid_post)
    post_to_delete.user = @user
    post_to_delete.save
    
    post '/xmlrpc/',  "<methodCall>
     <methodName>blogger.deletePost</methodName>
     <params>
      <param>
       <value>
        <string>0123456789ABCDEF</string>
       </value>
      </param>
      <param>
       <value>
        <string>#{post_to_delete.id}</string>
       </value>
      </param>
      <param>
       <value>
        <string>api@email.com</string>
       </value>
      </param>
      <param>
       <value>
        <string>password111</string>
       </value>
      </param>
      <param>
       <value>
        <boolean>1</boolean>
       </value>
      </param>
     </params>
    </methodCall>"
    
    Post.first(:id => post_to_delete.id).is_active.should be_false
    last_response.body.should include("<boolean>1</boolean>")
    
  end
  
  #Wordpress - Pages
  
  it "should return correct response when the getPages method is called" do
    
    page = Factory(:valid_page)
    page.user = @user
    page.save
    
    post '/xmlrpc/',  "<methodCall> 
                      <methodName>wp.getPages</methodName>
                       <params>
                        <param>
                         <value>
                          <string>2000</string>
                         </value>
                        </param>
                        <param>
                         <value>
                          <string>api@email.com</string>
                         </value>
                        </param>
                        <param>
                         <value>
                          <string>password111</string>
                         </value>
                        </param>
                        <param>
                         <value>
                          <int>50</int>
                         </value>
                        </param>
                       </params>
                      </methodCall>"

    find_value(last_response.body, "page_id", ["member", "name", "value", "i4"]).should == page.id.to_s
    find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == page.title
    find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == page.body
    find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == page.permalink
    find_value(last_response.body, "mt_convert_breaks", ["member", "name", "value", "string"]).should == "__default__"
    find_value(last_response.body, "dateCreated", ["member", "name", "value",  "dateTime.iso8601"]).should == page.created_at_iso8601
    find_value(last_response.body, "page_parent_id", ["member", "name", "value", "i4"]).should == 0.to_s
    
    page.destroy
  end
  
  it "should return correct response when the getPage method is called" do
    
    page = Factory(:valid_page)
    page.user = @user
    page.save
    
    post '/xmlrpc/',  "<methodCall>
                       <methodName>wp.getPage</methodName>
                       <params>
                        <param>
                         <value>
                          <string>2000</string>
                         </value>
                        </param>
                        <param>
                         <value>
                          <string>#{page.id.to_s}</string>
                         </value>
                        </param>
                        <param>
                         <value>
                          <string>api@email.com</string>
                         </value>
                        </param>
                        <param>
                         <value>
                          <string>password111</string>
                         </value>
                        </param>
                       </params>
                      </methodCall>"

    find_value(last_response.body, "page_id", ["member", "name", "value", "i4"]).should == page.id.to_s
    find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == page.title
    find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == page.body
    find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == page.permalink
    find_value(last_response.body, "mt_convert_breaks", ["member", "name", "value", "string"]).should == "__default__"
    find_value(last_response.body, "dateCreated", ["member", "name", "value",  "dateTime.iso8601"]).should == page.created_at_iso8601
    find_value(last_response.body, "page_parent_id", ["member", "name", "value", "i4"]).should == 0.to_s
    
    page.destroy
  end
  
  it "should return correct response and update record when the editPage method is called" do
    
    page = Factory(:valid_page)
    page.user = @user
    page.save
    
    post '/xmlrpc/',  "<methodCall>
     <methodName>wp.editPage</methodName>
     <params>
      <param>
       <value>
        <string>2000</string>
       </value>
      </param>
      <param>
       <value>
        <string>#{page.id.to_s}</string>
       </value>
      </param>
      <param>
       <value>
        <string>api@email.com</string>
       </value>
      </param>
      <param>
       <value>
        <string>password111</string>
       </value>
      </param>
      <param>
       <value>
        <struct>
         <member>
          <name>title</name>
          <value>
           <string>Page Test Update</string>
          </value>
         </member>
         <member>
          <name>description</name>
          <value>
           <string>Update</string>
          </value>
         </member>
         <member>
          <name>mt_keywords</name>
          <value>
           <string />
          </value>
         </member>
        </struct>
       </value>
      </param>
      <param>
       <value>
        <boolean>1</boolean>
       </value>
      </param>
     </params>
    </methodCall>"

    page.reload
    page.title.should == "Page Test Update"
    page.tags.should include("page")
    page.categories.should include ("page")
    page.body.should == "Update"
    last_response.body.should include("<boolean>1</boolean>")

    
    page.destroy
  end
 
  it "should return mark the record as inactive when the detelePage method is called" do
    
    page = Factory(:valid_page)
    page.user = @user
    page.save
    
    post '/xmlrpc/',  "<methodCall>
     <methodName>wp.deletePage</methodName>
     <params>
      <param>
       <value>
        <string>2000</string>
       </value>
      </param>
      <param>
       <value>
        <string>api@email.com</string>
       </value>
      </param>
      <param>
       <value>
        <string>password111</string>
       </value>
      </param>
      <param>
       <value>
        <string>#{page.id.to_s}</string>
       </value>
      </param>
     </params>
    </methodCall>"

    page.reload
    page.is_active.should be_false
    last_response.body.should include("<boolean>1</boolean>")

    
    page.destroy
  end 
  
  it "should return create a new record when the newPage method is called" do
    
    post '/xmlrpc/',  "<methodCall>
     <methodName>wp.newPage</methodName>
     <params>
      <param>
       <value>
        <string>2000</string>
       </value>
      </param>
      <param>
       <value>
        <string>api@email.com</string>
       </value>
      </param>
      <param>
       <value>
        <string>password111</string>
       </value>
      </param>
      <param>
       <value>
        <struct>
         <member>
          <name>title</name>
          <value>
           <string>Title New Page</string>
          </value>
         </member>
         <member>
          <name>description</name>
          <value>
           <string>&lt;p&gt;Body New Page&lt;/p&gt;</string>
          </value>
         </member>
         <member>
          <name>mt_keywords</name>
          <value>
           <string />
          </value>
         </member>
        </struct>
       </value>
      </param>
      <param>
       <value>
        <boolean>1</boolean>
       </value>
      </param>
     </params>
    </methodCall>
    "

    page = Post.first(:title => "Title New Page")
    page.is_page.should be_true
    page.title.should ==  "Title New Page"
    page.body.should == "<p>Body New Page</p>"
    page.tags.should include("page")
    page.categories.should include("page")
    page.is_active.should be_true
    last_response.body.should include("<i4>#{page.id.to_s}</i4>")

    
    page.destroy
  end
  
  
  it "should return correct response when the getAuthors method is called" do

    
    post '/xmlrpc/',  "<methodCall>
                      <methodName>wp.getAuthors</methodName>
                      <params>
                      <param>
                       <value>
                        <string>2000</string>
                       </value>
                      </param>
                      <param>
                       <value>
                        <string>api@email.com</string>
                       </value>
                      </param>
                      <param>
                       <value>
                        <string>password111</string>
                       </value>
                      </param>
                      </params>
                      </methodCall>"

    find_value(last_response.body, "user_id", ["member", "name", "value", "i4"]).should == @user.id.to_s
    find_value(last_response.body, "user_login", ["member", "name", "value", "string"]).should == @user.email
    find_value(last_response.body, "display_name", ["member", "name", "value", "string"]).should == @user.fullname
    find_value(last_response.body, "user_email", ["member", "name", "value", "string"]).should == @user.email


  end
  
  it "should return correct response when the getTags method is called" do

    
    post '/xmlrpc/',  "<methodCall>
                       <methodName>wp.getTags</methodName>
                       <params>
                        <param>
                         <value>
                          <string>2000</string>
                         </value>
                        </param>
                        <param>
                         <value>
                          <string>api@email.com</string>
                         </value>
                        </param>
                        <param>
                         <value>
                          <string>password111</string>
                         </value>
                        </param>
                       </params>
                      </methodCall>"

    find_value(last_response.body, "name", ["member", "name", "value", "string"], 0).should == "cat1"               
    find_value(last_response.body, "name", ["member", "name", "value", "string"], 1).should == "cat2"                
  end
  
  private 
  def find_value(xml, find, hierarchy = [], nth = nil)
    return Nokogiri::XML(xml).xpath("//#{hierarchy[0]}/#{hierarchy[1]}[text()='#{find}']")[nth.nil? ? 0 : nth].parent.xpath("#{hierarchy[2]}/#{hierarchy[3]}").text
  end
  
end