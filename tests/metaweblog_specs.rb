require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

describe "metaweblog api" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  
  before(:all) do  
    TestDataHelper.wipe_database
    @user = TestDataHelper.valid_user
    @post = TestDataHelper.valid_post
    #need to put some time between post saves.... a second will do just to give the ordering some meaning
    sleep(1.5)
    @second_post = TestDataHelper.valid_post1
    @page = TestDataHelper.valid_page
  end
    
  it "should return correct response when the listMethods method is called and not require authentication" do
    post '/xmlrpc/', "<methodCall><methodName>system.listMethods</methodName><params></params></methodCall>"
    
    last_response.should be_ok
    last_response.body.should include("metaWeblog.newMediaObject")
    
  end
  it "should return correct response when the getUserInfo method is called" do
    post '/xmlrpc/',     "<methodCall> 
                          <methodName>blogger.getUserInfo</methodName>
                          <params>
                          <param><value><string>Blog Name</string></value></param>
                          <param><value><string>#{@user.email}</string></value></param>
                          <param><value><string>password123</string></value></param>
                          </params>
                          </methodCall>"
  
    find_value(last_response.body, "userid", ["member", "name", "value", "i4"]).should == @user.id.to_s
    find_value(last_response.body, "firstname", ["member", "name", "value", "string"]).should == @user.firstname
    find_value(last_response.body, "lastname", ["member", "name", "value", "string"]).should == @user.lastname
    find_value(last_response.body, "url", ["member", "name", "value", "string"]).should == Blog.url
    find_value(last_response.body, "email", ["member", "name", "value", "string"]).should == @user.email
    find_value(last_response.body, "nickname", ["member", "name", "value", "string"]).should == @user.fullname
  end
  
  it "should return correct response when the getUsersBlogs method is called" do
     post '/xmlrpc/',     "<methodCall>
                           <methodName>blogger.getUsersBlogs</methodName>
                           <params>
                           <param><value><string>Blog Name</string></value></param>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
                           </params>
                           </methodCall>"
                       
     find_value(last_response.body, "url", ["member", "name", "value", "string"]).should == Blog.url
     find_value(last_response.body, "blogid", ["member", "name", "value", "i4"]).should == "2000"
     find_value(last_response.body, "blogName", ["member", "name", "value", "string"]).should == Blog.site_name
   end
   
   it "should return correct response when the getUsersBlogs method is called with the wordpress prefix" do
     post '/xmlrpc/',     "<methodCall>
                           <methodName>wp.getUsersBlogs</methodName>
                           <params>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
                           </params>
                           </methodCall>"
                       
                           find_value(last_response.body, "isAdmin", ["member", "name", "value", "i4"]).should == 1.to_s
                           find_value(last_response.body, "url", ["member", "name", "value", "string"]).should == Blog.url
                           find_value(last_response.body, "blogid", ["member", "name", "value", "i4"]).should == "2000"
                           find_value(last_response.body, "blogName", ["member", "name", "value", "string"]).should == Blog.site_name
                           find_value(last_response.body, "xmlrpc", ["member", "name", "value", "string"]).should == "#{Blog.url}/xmlrpc.php"
   end
   
   it "should return correct response when the getRecentPosts method is called" do
     post '/xmlrpc/',     "<methodCall> 
                           <methodName>metaWeblog.getRecentPosts</methodName>
                           <params>
                           <param><value><string>Blog Name</string></value></param>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
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
     find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"], 0).should == @second_post.readable_tags.gsub(" ", "")
     find_value(last_response.body, "publish", ["member", "name", "value", "boolean"], 0).should == "1"
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"], 0).should == @second_post.categories[0].category
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"], 0).should == @second_post.categories[1].category
     
     find_value(last_response.body, "postid", ["member", "name", "value", "i4"], 1).should == @post.id.to_s
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 1).should == @post.created_at_iso8601
     find_value(last_response.body, "title", ["member", "name", "value", "string"], 1).should == @post.title
     find_value(last_response.body, "description", ["member", "name", "value", "string"], 1).should == @post.body
     find_value(last_response.body, "link", ["member", "name", "value", "string"], 1).should == @post.permalink
     find_value(last_response.body, "wp_slug", ["member", "name", "value", "string"], 1).should == @post.slug
     find_value(last_response.body, "mt_excerpt", ["member", "name", "value", "string"], 1).should == ""
     find_value(last_response.body, "mt_allow_comments", ["member", "name", "value", "string"], 1).should == ""
     find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"], 1).should == @post.readable_tags.gsub(" ", "")
     find_value(last_response.body, "publish", ["member", "name", "value", "boolean"], 1).should == "1"
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"], 1).should == @post.categories[0].category
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"], 1).should == @post.categories[1].category
      
  end
   
   it "should return correct response when the getPost method is called" do
     post '/xmlrpc/',  "<methodCall> 
                           <methodName>metaWeblog.getPost</methodName>
                           <params>
                           <param><value><string>#{@second_post.id.to_s}</string></value></param>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
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
     find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"]).should == @second_post.readable_tags.gsub(" ", "")
     find_value(last_response.body, "publish", ["member", "name", "value", "boolean"]).should == "1"
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"]).should == @second_post.categories[0].category
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"]).should == @second_post.categories[1].category
   end
   
   it "should return correct response when the getCategories method is called" do
     post '/xmlrpc/',  "<methodCall>
                           <methodName>blogger.getCategories</methodName>
                           <params>
                           <param><value><string>Blog Name</string></value></param>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
                           </params>
                           </methodCall>"
                                     
     category1 = TestDataHelper.category1
     category2 = TestDataHelper.category2
     
     find_value(last_response.body, "categoryId", ["member", "name", "value", "i4"], 0).should == category1.id.to_s 
     find_value(last_response.body, "parentId", ["member", "name", "value", "i4"], 0).should == "0" 
     find_value(last_response.body, "description", ["member", "name", "value", "string"], 0).should == category1.category             
     find_value(last_response.body, "categoryDescription", ["member", "name", "value", "string"], 0).should == ""
     find_value(last_response.body, "categoryName", ["member", "name", "value", "string"], 0).should == category1.category
     find_value(last_response.body, "htmlUrl", ["member", "name", "value", "string"], 0).should == category1.permalink
     find_value(last_response.body, "rssUrl", ["member", "name", "value", "string"], 0).should == ""
     find_value(last_response.body, "title", ["member", "name", "value", "string"], 0).should == category1.category
     
     find_value(last_response.body, "categoryId", ["member", "name", "value", "i4"], 1).should == category2.id.to_s  
     find_value(last_response.body, "parentId", ["member", "name", "value", "i4"], 1).should == "0" 
     find_value(last_response.body, "description", ["member", "name", "value", "string"], 1).should == category2.category                 
     find_value(last_response.body, "categoryDescription", ["member", "name", "value", "string"], 1).should == ""
     find_value(last_response.body, "categoryName", ["member", "name", "value", "string"], 1).should == category2.category 
     find_value(last_response.body, "htmlUrl", ["member", "name", "value", "string"], 1).should == category2.permalink
     find_value(last_response.body, "rssUrl", ["member", "name", "value", "string"], 1).should == ""
     find_value(last_response.body, "title", ["member", "name", "value", "string"], 1).should == category2.category 
   end
   
   it "should update the correct post and give the correct response when the editPost method is called" do
     
     post_to_update_id = @post.id
     old_post_slug = @post.slug
     
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
         <string>#{@user.email}</string>
        </value>
       </param>
       <param>
        <value>
         <string>password123</string>
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
               <string>category10</string>
              </value>
              <value>
               <string>category11</string>
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
     post.legacy_routes[0].slug.should == old_post_slug
     post.month.should == "February"
     post.year.should == 2011
     post.categories[0].category.should == "category10"
     post.categories[1].category.should == "category11"
     
     find_value(last_response.body, "postid", ["member", "name", "value", "i4"]).should == post_to_update_id.to_s
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"]).should == post.created_at_iso8601
     find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == post.title
     find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == post.body
     find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == post.permalink
     find_value(last_response.body, "wp_slug", ["member", "name", "value", "string"]).should == post.slug
     find_value(last_response.body, "mt_excerpt", ["member", "name", "value", "string"]).should == ""
     find_value(last_response.body, "mt_allow_comments", ["member", "name", "value", "string"]).should == ""
     find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"]).should == post.readable_tags.gsub(" ", "")
     find_value(last_response.body, "publish", ["member", "name", "value", "boolean"]).should == "1"
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"]).should == "category10"
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"]).should == "category11"
     
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
         <string>#{@user.email}</string>
         </value>
        </param>
        <param>
         <value>
          <string>password123</string>
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
                <string>category1</string>
               </value>
               <value>
                <string>category2</string>
               </value>
               <value>
                <string>category3</string>
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
      post.categories[0].category.should == "category1"
      post.categories[1].category.should == "category2"
      post.categories[2].category.should == "category3"
      
      post.month.should == DateTime.now.strftime("%B")
      post.year.should == DateTime.now.year
      post.is_active.should be_true
      
      last_response.body.should include("<i4>#{post.id}</i4>")
    end
   
   it "should mark a post as not published and give the correct response when the deletePost method is called" do  
     
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
         <string>#{@post.id}</string>
        </value>
       </param>
       <param>
        <value>
         <string>#{@user.email}</string>
        </value>
       </param>
       <param>
        <value>
         <string>password123</string>
        </value>
       </param>
       <param>
        <value>
         <boolean>1</boolean>
        </value>
       </param>
      </params>
     </methodCall>"
     
     @post.reload.is_active.should be_false
     last_response.body.should include("<boolean>1</boolean>")
     
     #tear down this test
     @post.is_active = true
     @post.save
     @post.reload
     
   end
   
   #Wordpress - Pages
   
   it "should return correct response when the getPages method is called" do
     
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
                           <string>#{@user.email}</string>
                          </value>
                         </param>
                         <param>
                          <value>
                           <string>password123</string>
                          </value>
                         </param>
                         <param>
                          <value>
                           <int>50</int>
                          </value>
                         </param>
                        </params>
                       </methodCall>"
  
     find_value(last_response.body, "page_id", ["member", "name", "value", "i4"]).should == @page.id.to_s
     find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == @page.title
     find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == @page.body
     find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == @page.permalink
     find_value(last_response.body, "mt_convert_breaks", ["member", "name", "value", "string"]).should == "__default__"
     find_value(last_response.body, "dateCreated", ["member", "name", "value",  "dateTime.iso8601"]).should == @page.created_at_iso8601
     find_value(last_response.body, "page_parent_id", ["member", "name", "value", "i4"]).should == 0.to_s
     
   end
   
   it "should return correct response when the getPage method is called" do
     
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
                           <string>#{@page.id.to_s}</string>
                          </value>
                         </param>
                         <param>
                          <value>
                           <string>#{@user.email}</string>
                          </value>
                         </param>
                         <param>
                          <value>
                           <string>password123</string>
                          </value>
                         </param>
                        </params>
                       </methodCall>"
  
     find_value(last_response.body, "page_id", ["member", "name", "value", "i4"]).should == @page.id.to_s
     find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == @page.title
     find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == @page.body
     find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == @page.permalink
     find_value(last_response.body, "mt_convert_breaks", ["member", "name", "value", "string"]).should == "__default__"
     find_value(last_response.body, "dateCreated", ["member", "name", "value",  "dateTime.iso8601"]).should == @page.created_at_iso8601
     find_value(last_response.body, "page_parent_id", ["member", "name", "value", "i4"]).should == 0.to_s
   end
   
   it "should return correct response and update record when the editPage method is called" do
     
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
         <string>#{@page.id.to_s}</string>
        </value>
       </param>
       <param>
        <value>
         <string>#{@user.email}</string>
        </value>
       </param>
       <param>
        <value>
         <string>password123</string>
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
  
     @page.reload
     @page.title.should == "Page Test Update"
     @page.tags[0].tag.should == "page"
     @page.categories[0].category.should == "page"
     @page.body.should == "Update"
     @page.legacy_routes[0].slug.should == "valid-page"
     @page.year.nil?.should be_false
     last_response.body.should include("<boolean>1</boolean>")
   end
  
   it "should return mark the record as inactive when the detelePage method is called" do

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
         <string>#{@user.email}</string>
        </value>
       </param>
       <param>
        <value>
         <string>password123</string>
        </value>
       </param>
       <param>
        <value>
         <string>#{@page.id.to_s}</string>
        </value>
       </param>
      </params>
     </methodCall>"
  
     @page.reload
     @page.is_active.should be_false
     last_response.body.should include("<boolean>1</boolean>")
   end 
   
   it "should return a list of pages getPageList method is called" do
     @page = TestDataHelper.valid_page
     
     post '/xmlrpc/',  "<methodCall>
                            <methodName>wp.getPageList</methodName>
                            <params>
                            <param>
                             <value>
                              <string>2000</string>
                             </value>
                            </param>
                            <param>
                             <value>
                              <string>#{@user.email}</string>
                             </value>
                            </param>
                            <param>
                             <value>
                              <string>password123</string>
                             </value>
                            </param>
                            </params>
                            </methodCall>"
  
     find_value(last_response.body, "page_id", ["member", "name", "value", "i4"], 0).should == @page.id.to_s
     find_value(last_response.body, "page_title", ["member", "name", "value", "string"], 0).should == @page.title
     find_value(last_response.body, "page_parent_id", ["member", "name", "value", "i4"], 0).should == "0"
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 0).should == @page.created_at_iso8601
     find_value(last_response.body, "date_created_gmt", ["member", "name", "value", "dateTime.iso8601"], 0).should == @page.created_at_iso8601   
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
         <string>#{@user.email}</string>
        </value>
       </param>
       <param>
        <value>
         <string>password123</string>
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
     page.tags[0].tag.should == "page"
     page.categories[0].category.should == "page"
     page.is_active.should be_true
     page.year.nil?.should be_false
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
                         <string>#{@user.email}</string>
                        </value>
                       </param>
                       <param>
                        <value>
                         <string>password123</string>
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
  
       tags = Tag.usable_active_tags
       
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
                             <string>#{@user.email}</string>
                            </value>
                           </param>
                           <param>
                            <value>
                             <string>password123</string>
                            </value>
                           </param>
                          </params>
                         </methodCall>"
    
       find_value(last_response.body, "tag_id", ["member", "name", "value", "i4"], 0).should == tags[0].id.to_s
       find_value(last_response.body, "name", ["member", "name", "value", "string"], 0).should == tags[0].tag
       find_value(last_response.body, "count", ["member", "name", "value", "i4"], 0).should == tags[0].posts.count.to_s
       find_value(last_response.body, "slug", ["member", "name", "value", "string"], 0).should == tags[0].tag
       find_value(last_response.body, "html_url", ["member", "name", "value", "string"], 0).should == tags[0].permalink
       find_value(last_response.body, "rss_url", ["member", "name", "value", "string"], 0).should == ""
       
       find_value(last_response.body, "tag_id", ["member", "name", "value", "i4"], 1).should == tags[1].id.to_s            
       find_value(last_response.body, "name", ["member", "name", "value", "string"], 1).should == tags[1].tag
       find_value(last_response.body, "count", ["member", "name", "value", "i4"], 1).should == tags[1].posts.count.to_s   
       find_value(last_response.body, "slug", ["member", "name", "value", "string"], 1).should == tags[1].tag  
       find_value(last_response.body, "html_url", ["member", "name", "value", "string"], 1).should == tags[1].permalink 
       find_value(last_response.body, "rss_url", ["member", "name", "value", "string"], 1).should == ""           
     end
     
  
     it "should return create a new record when the newCategory method is called" do

       post '/xmlrpc/',  "<methodCall>
        <methodName>wp.newCategory</methodName>
        <params>
         <param>
          <value>
           <string>2000</string>
          </value>
         </param>
         <param>
          <value>
           <string>#{@user.email}</string>
          </value>
         </param>
         <param>
          <value>
           <string>password123</string>
          </value>
         </param>
         <param>
          <value>
           <struct>
            <member>
             <name>name</name>
             <value>
              <string>Category - Metaweblog</string>
             </value>
            </member>
            <member>
             <name>slug</name>
             <value>
              <string>not relevent</string>
             </value>
            </member>
            <member>
             <name>parent_id</name>
             <value>
              <string>0</string>
             </value>
            </member>
            <member>
             <name>description</name>
             <value>
              <string>Category - Metaweblog</string>
             </value>
            </member>
           </struct>
          </value>
         </param>
        </params>
       </methodCall>"

       category = Category.first(:category => "Category - Metaweblog")
       category.category.should ==  "Category - Metaweblog"
       last_response.body.should include("<i4>#{category.id.to_s}</i4>")

     end
  
     it "should mark a record as inactive when the deleteCategory method is called" do
       category = Category.first(:category => "Category - Metaweblog")

       post '/xmlrpc/',  "<methodCall>
        <methodName>wp.deleteCategory</methodName>
        <params>
         <param>
          <value>
           <string>2000</string>
          </value>
         </param>
         <param>
          <value>
           <string>#{@user.email}</string>
          </value>
         </param>
         <param>
          <value>
           <string>password123</string>
          </value>
         </param>
         <param>
          <value>
           <string>#{category.id.to_s}</string>
          </value>
         </param>
        </params>
       </methodCall>"

       category.reload
       category.is_active.should ==  false
       last_response.body.should include("<boolean>1</boolean>")
       category.destroy
     end
     
     it "should not mark a record as inactive when the deleteCategory method is called and the category has posts" do
       
       post '/xmlrpc/',  "<methodCall>
        <methodName>wp.deleteCategory</methodName>
        <params>
         <param>
          <value>
           <string>2000</string>
          </value>
         </param>
         <param>
          <value>
           <string>#{@user.email}</string>
          </value>
         </param>
         <param>
          <value>
           <string>password123</string>
          </value>
         </param>
         <param>
          <value>
           <string>#{TestDataHelper.category1.id.to_s}</string>
          </value>
         </param>
        </params>
       </methodCall>"

       TestDataHelper.category1.is_active.should ==  true
       last_response.body.should include("<boolean>0</boolean>")

     end
     
     it "should return the correct caregories when the suggestCategories method is called" do
       
       post '/xmlrpc/',  "<methodCall>
               <methodName>wp.suggestCategories</methodName>
               <params>
                <param>
                 <value>
                  <string>2000</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>#{@user.email}</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>password123</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>cat</string>
                 </value>
                </param>
                <param>
                 <value>
                  <i4>2</i4>
                 </value>
                </param>
               </params>
              </methodCall>"

       find_value(last_response.body, "category_name", ["member", "name", "value", "string"], 0).should include("category")
       find_value(last_response.body, "category_name", ["member", "name", "value", "string"], 1).should include("category")

     end
     
     it "should return the correct comment count for a post when the getCommentCount method is called" do
       TestDataHelper.load_all_comments
       post = TestDataHelper.valid_post
       
       post '/xmlrpc/',  "<methodCall>
               <methodName>wp.getCommentCount</methodName>
               <params>
                <param>
                 <value>
                  <string>2000</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>#{@user.email}</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>password123</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>#{post.id}</string>
                 </value>
                </param>
                </params>
              </methodCall>"
       find_value(last_response.body, "total_comments", ["member", "name", "value", "i4"]).should == "2"
     end
     
     it "should return the correct shout mouth option when the getOptions method is called" do
       TestDataHelper.load_all_comments
       post = TestDataHelper.valid_post
       
       post '/xmlrpc/',  "<methodCall>
               <methodName>wp.getOptions</methodName>
               <params>
                <param>
                 <value>
                  <string>2000</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>#{@user.email}</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>password123</string>
                 </value>
                </param>
                </params>
              </methodCall>"
       find_value(last_response.body, "software_name", ["member", "name", "value", "struct/member/name[text()='value']/../value/string"]).should == "ShoutMouth"
       find_value(last_response.body, "blog_url", ["member", "name", "value", "struct/member/name[text()='value']/../value/string"]).should == Blog.url
       find_value(last_response.body, "blog_title", ["member", "name", "value", "struct/member/name[text()='value']/../value/string"]).should == Blog.site_name
       find_value(last_response.body, "blog_tagline", ["member", "name", "value", "struct/member/name[text()='value']/../value/string"]).should == Blog.site_description
     end
     
     it "should return the correct comments when the getComments method is called" do
       TestDataHelper.load_all_comments
       post_id = TestDataHelper.valid_post.id
       
       
       post '/xmlrpc/',  "<methodCall>
                         	<methodName>wp.getComments</methodName>
                         	<params>
                         		<param>
                         			<value>
                         				<string>2000</string>
                         			</value>
                         		</param>
                         		<param>
                         			<value>
                                <string>#{@user.email}</string>
                         			</value>
                         		</param>
                         		<param>
                         			<value>
                         				<string>password123</string>
                         			</value>
                         		</param>
                         		<param>
                         			<value>
                         				<struct>
                         					<member>
                         						<name>number</name>
                         						<value>
                         							<i4>3</i4>
                         						</value>
                                 </member>
                         					<member>
                         						<name>status</name>
                         						<value>
                         							<string>spam</string>
                         						</value>
                         					</member>
                         					<member>
                         						<name>post_id</name>
                         						<value>
                         							<i4>#{post_id}</i4>
                         						</value>
                         					</member>
                         				</struct>
                         			</value>
                         		</param>
                         	</params>
                         </methodCall>"
       #Dont need to rest all the correct values are spat out. - This is done in the previous test
       #Just checking for 3 comments all with post id of post_id
       
       find_value(last_response.body, "post_id", ["member", "name", "value", "i4"], 0).should == post_id.to_s
       find_value(last_response.body, "post_id", ["member", "name", "value", "i4"], 1).should == post_id.to_s
       find_value(last_response.body, "post_id", ["member", "name", "value", "i4"], 2).should == post_id.to_s
       lambda{ find_value(last_response.body, "post_id", ["member", "name", "value", "i4"], 3)}.should raise_error
     end
     
     it "should return the correct comment when the getComment method is called" do
       comment = TestDataHelper.valid_comment
       
       
       post '/xmlrpc/',  "<methodCall>
               <methodName>wp.getComment</methodName>
               <params>
                <param>
                 <value>
                  <string>2000</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>#{@user.email}</string>
                 </value>
                </param>
                <param>
                 <value>
                  <string>password123</string>
                 </value>
                </param>
                <param>
                 <value>
                  <i4>#{comment.id}</i4>
                 </value>
                </param>
                </params>
              </methodCall>"
                     
       find_value(last_response.body, "date_created_gmt", ["member", "name", "value", "dateTime.iso8601"]).should == comment.created_at_iso8601
       find_value(last_response.body, "user_id", ["member", "name", "value", "string"]).should == comment.comment_author_email
       find_value(last_response.body, "comment_id", ["member", "name", "value", "i4"]).should == comment.id.to_s
       find_value(last_response.body, "parent", ["member", "name", "value", "i4"]).should == "0"
       find_value(last_response.body, "parent", ["member", "name", "value", "i4"]).should == "0"
       find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == comment.post.permalink
       find_value(last_response.body, "post_id", ["member", "name", "value", "i4"]).should == comment.post.id.to_s
       find_value(last_response.body, "post_title", ["member", "name", "value", "string"]).should == comment.post.title
       find_value(last_response.body, "author", ["member", "name", "value", "string"]).should == comment.comment_author
       find_value(last_response.body, "author_url", ["member", "name", "value", "string"]).should == comment.comment_author_url
       find_value(last_response.body, "author_email", ["member", "name", "value", "string"]).should == comment.comment_author_email
       find_value(last_response.body, "author_ip", ["member", "name", "value", "string"]).should == comment.user_ip
      
     end
     
     it "should return the correct comment status list when the getCommentStatusList method is called" do
       comment = TestDataHelper.valid_comment
       
       
       post '/xmlrpc/',  "<methodCall>
       	<methodName>wp.getCommentStatusList</methodName>
       	<params>
       		<param>
       			<value>
       				<string>2000</string>
       			</value>
       		</param>
       		<param>
       			<value>
       				<string>#{@user.email}</string>
       			</value>
       		</param>
       		<param>
       			<value>
       				<string>password123</string>
       			</value>
       		</param>
       	</params>
       </methodCall>
       "
                     
       find_value(last_response.body, "approve", ["member", "name", "value", "string"]).should == "Approved"
       find_value(last_response.body, "hold", ["member", "name", "value", "string"]).should == "Unapproved"
       find_value(last_response.body, "spam", ["member", "name", "value", "string"]).should == "Spam"
      
     end
     
     it "should mark a comment as inactive when the deleteComment method is called" do
       comment = TestDataHelper.valid_comment
       
       
       post '/xmlrpc/',  "<methodCall>
       	<methodName>wp.deleteComment</methodName>
       	<params>
       		<param>
       			<value>
       				<string>2000</string>
       			</value>
       		</param>
       		<param>
       			<value>
       				<string>#{@user.email}</string>
       			</value>
       		</param>
       		<param>
       			<value>
       				<string>password123</string>
       			</value>
       		</param>
       		<param>
       			<value>
       				<string>#{comment.id}</string>
       			</value>
       		</param>
       	</params>
       </methodCall>
       "
       comment.reload
       comment.is_active.should be_false  
       last_response.body.should include("<boolean>1</boolean>")
     end
     
     it "should edit a comment the editComment method is called" do
       comment = TestDataHelper.valid_comment
 
       post '/xmlrpc/',  "<methodCall>
       	<methodName>wp.editComment</methodName>
       	<params>
       		<param>
       			<value>
       				<string>2000</string>
       			</value>
       		</param>
       		<param>
       			<value>
       				<string>#{@user.email}</string>
       			</value>
       		</param>
       		<param>
       			<value>
       				<string>password123</string>
       			</value>
       		</param>
       		<param>
       			<value>
       				<string>#{comment.id}</string>
       			</value>
       		</param>
          <param>
    			<value>
     				<struct>
     					<member>
     						<name>status</name>
     						<value>
     							<string>approve</string>
     						</value>
             </member>
             	<member>
     						<name>date_created_gmt</name>
     						<value>
     							 <dateTime.iso8601>20110221T21:41:00</dateTime.iso8601>
     						</value>
             </member>
             	<member>
     						<name>content</name>
     						<value>
     							  <string>This should get everyone talking again!</string>
     						</value>
             </member>
             	<member>
     						<name>author</name>
     						<value>
     							  <string>Dan Watson</string>
     						</value>
             </member>
             	<member>
     						<name>author_url</name>
     						<value>
     							  <string>http://www.google.com</string>
     						</value>
             </member>
             	<member>
     						<name>author_email</name>
     						<value>
     							  <string>dan1@shout_mouth.com</string>
     						</value>
             </member>
     				</struct>
     			</value>
     		</param>
       	</params>
       </methodCall>
       "

       comment.reload
       comment.is_active.should be_true
       comment.comment_content.should == "This should get everyone talking again!"
       comment.comment_author.should == "Dan Watson"
       comment.comment_author_email.should == "dan1@shout_mouth.com"
       
       last_response.body.should include("<boolean>1</boolean>")
     end
  
  private 
  def find_value(xml, find, hierarchy = [], nth = nil)
    return Nokogiri::XML(xml).xpath("//#{hierarchy[0]}/#{hierarchy[1]}[text()='#{find}']")[nth.nil? ? 0 : nth].parent.xpath("#{hierarchy[2]}/#{hierarchy[3]}").text
  end
  
end