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
  
    find_value(last_response.body, "userid", ["member", "name", "value", "string"]).should == @user.id.to_s
    find_value(last_response.body, "firstname", ["member", "name", "value", "string"]).should == @user.firstname
    find_value(last_response.body, "lastname", ["member", "name", "value", "string"]).should == @user.lastname
    find_value(last_response.body, "url", ["member", "name", "value", "string"]).should == Blog.url
    #find_value(last_response.body, "email", ["member", "name", "value", "string"]).should == @user.email
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
     find_value(last_response.body, "blogid", ["member", "name", "value", "int"]).should == "2000"
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
                       
                           find_value(last_response.body, "isAdmin", ["member", "name", "value", "boolean"]).should == 1.to_s
                           find_value(last_response.body, "url", ["member", "name", "value", "string"]).should == Blog.url
                           find_value(last_response.body, "blogid", ["member", "name", "value", "int"]).should == "2000"
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
     find_value(last_response.body, "postid", ["member", "name", "value", "string"], 0).should == @second_post.id.to_s
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 0).should == @second_post.created_at_iso8601
     find_value(last_response.body, "title", ["member", "name", "value", "string"], 0).should == @second_post.title
     find_value(last_response.body, "description", ["member", "name", "value", "string"], 0).should == @second_post.body
     find_value(last_response.body, "link", ["member", "name", "value", "string"], 0).should == @second_post.permalink
     find_value(last_response.body, "wp_slug", ["member", "name", "value", "string"], 0).should == @second_post.slug
     find_value(last_response.body, "mt_excerpt", ["member", "name", "value", "string"], 0).should == ""
     find_value(last_response.body, "mt_allow_comments", ["member", "name", "value", "int"], 0).should == "1"
     find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"], 0).should == @second_post.readable_tags.gsub(" ", "")
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"], 0).should == @second_post.categories[0].category
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"], 0).should == @second_post.categories[1].category
     
     find_value(last_response.body, "postid", ["member", "name", "value", "string"], 1).should == @post.id.to_s
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 1).should == @post.created_at_iso8601
     find_value(last_response.body, "title", ["member", "name", "value", "string"], 1).should == @post.title
     find_value(last_response.body, "description", ["member", "name", "value", "string"], 1).should == @post.body
     find_value(last_response.body, "link", ["member", "name", "value", "string"], 1).should == @post.permalink
     find_value(last_response.body, "wp_slug", ["member", "name", "value", "string"], 1).should == @post.slug
     find_value(last_response.body, "mt_excerpt", ["member", "name", "value", "string"], 1).should == ""
     find_value(last_response.body, "mt_allow_comments", ["member", "name", "value", "int"], 1).should == "1"
     find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"], 1).should == @post.readable_tags.gsub(" ", "")
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"], 1).should == @post.categories[0].category
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"], 1).should == @post.categories[1].category
      
  end
  
   it "should return correct response when the getRecentPostTitle method is called using the movable type api" do
     post '/xmlrpc/',     "<methodCall> 
                           <methodName>mt.getRecentPostTitles</methodName>
                           <params>
                           <param><value><string>Blog Name</string></value></param>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
                           <param><value><i4>2</i4></value></param>
                           </params>
                           </methodCall>"
                           
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 0).should == @second_post.created_at_iso8601
     find_value(last_response.body, "userid", ["member", "name", "value", "string"], 0).should == @second_post.user.id.to_s
     find_value(last_response.body, "postid", ["member", "name", "value", "string"], 0).should == @second_post.id.to_s
     find_value(last_response.body, "title", ["member", "name", "value", "string"], 0).should == @second_post.title
     find_value(last_response.body, "date_created_gmt", ["member", "name", "value", "dateTime.iso8601"], 0).should == @second_post.created_at_iso8601

     
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 1).should == @post.created_at_iso8601
     find_value(last_response.body, "userid", ["member", "name", "value", "string"], 1).should == @post.user.id.to_s
     find_value(last_response.body, "postid", ["member", "name", "value", "string"], 1).should == @post.id.to_s
     find_value(last_response.body, "title", ["member", "name", "value", "string"], 1).should == @post.title
     find_value(last_response.body, "date_created_gmt", ["member", "name", "value", "dateTime.iso8601"], 1).should == @post.created_at_iso8601

  end
   it "should return correct response when the getRecentPosts method is called using the blogger api" do
     post '/xmlrpc/',     "<methodCall> 
                           <methodName>blogger.getRecentPosts</methodName>
                           <params>
                           <param><value><string>Blog Name</string></value></param>
                           <param><value><string>Blog Name</string></value></param>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
                           <param><value><i4>2</i4></value></param>
                           </params>
                           </methodCall>"
                           
                         
     find_value(last_response.body, "userid", ["member", "name", "value", "string"], 0).should == @second_post.user.id.to_s
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 0).should == @second_post.created_at_iso8601
     find_value(last_response.body, "content", ["member", "name", "value", "string"], 0).should include(@second_post.title)
     find_value(last_response.body, "postid", ["member", "name", "value", "string"], 0).should == @second_post.id.to_s

     
     find_value(last_response.body, "userid", ["member", "name", "value", "string"], 1).should == @post.user.id.to_s
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 1).should == @post.created_at_iso8601
     find_value(last_response.body, "content", ["member", "name", "value", "string"], 1).should include(@post.title)
     find_value(last_response.body, "postid", ["member", "name", "value", "string"], 1).should == @post.id.to_s
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
     find_value(last_response.body, "postid", ["member", "name", "value", "string"]).should == @second_post.id.to_s
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"]).should == @second_post.created_at_iso8601
     find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == @second_post.title
     find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == @second_post.body
     find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == @second_post.permalink
     find_value(last_response.body, "wp_slug", ["member", "name", "value", "string"]).should == @second_post.slug
     find_value(last_response.body, "mt_excerpt", ["member", "name", "value", "string"]).should == ""
     find_value(last_response.body, "mt_allow_comments", ["member", "name", "value", "int"]).should == "1"
     find_value(last_response.body, "mt_keywords", ["member", "name", "value", "string"]).should == @second_post.readable_tags.gsub(" ", "")
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[1]/string"]).should == @second_post.categories[0].category
     find_value(last_response.body, "categories", ["member", "name", "value", "array/data/value[2]/string"]).should == @second_post.categories[1].category
   end
   
   it "should return correct response when the getPost method is called using the blogger api" do
     post '/xmlrpc/',  "<methodCall> 
                           <methodName>blogger.getPost</methodName>
                           <params>
                           <param><value><string>Blog Name</string></value></param>
                           <param><value><string>#{@second_post.id.to_s}</string></value></param>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
                           </params>
                           </methodCall>"
     find_value(last_response.body, "userid", ["member", "name", "value", "string"]).should == @second_post.user.id.to_s
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"]).should == @second_post.created_at_iso8601
     find_value(last_response.body, "content", ["member", "name", "value", "string"]).should include(@second_post.body)
     find_value(last_response.body, "postid", ["member", "name", "value", "string"]).should == @second_post.id.to_s
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
     
     find_value(last_response.body, "categoryId", ["member", "name", "value", "string"], 0).should == category1.id.to_s 
     find_value(last_response.body, "parentId", ["member", "name", "value", "string"], 0).should == "0" 
     find_value(last_response.body, "description", ["member", "name", "value", "string"], 0).should == category1.category             
     find_value(last_response.body, "categoryDescription", ["member", "name", "value", "string"], 0).should == ""
     find_value(last_response.body, "categoryName", ["member", "name", "value", "string"], 0).should == category1.category
     find_value(last_response.body, "htmlUrl", ["member", "name", "value", "string"], 0).should == category1.permalink
     find_value(last_response.body, "rssUrl", ["member", "name", "value", "string"], 0).should == ""
     
     find_value(last_response.body, "categoryId", ["member", "name", "value", "string"], 1).should == category2.id.to_s  
     find_value(last_response.body, "parentId", ["member", "name", "value", "string"], 1).should == "0" 
     find_value(last_response.body, "description", ["member", "name", "value", "string"], 1).should == category2.category                 
     find_value(last_response.body, "categoryDescription", ["member", "name", "value", "string"], 1).should == ""
     find_value(last_response.body, "categoryName", ["member", "name", "value", "string"], 1).should == category2.category 
     find_value(last_response.body, "htmlUrl", ["member", "name", "value", "string"], 1).should == category2.permalink
     find_value(last_response.body, "rssUrl", ["member", "name", "value", "string"], 1).should == ""
   end
   
   it "should return correct response when the getCategoryList method is called with a movable type client" do
     post '/xmlrpc/',  "<methodCall>
                           <methodName>mt.getCategoryList</methodName>
                           <params>
                           <param><value><string>Blog Name</string></value></param>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
                           </params>
                           </methodCall>"
                                     
     category1 = TestDataHelper.category1
     category2 = TestDataHelper.category2
     
     find_value(last_response.body, "categoryId", ["member", "name", "value", "string"], 0).should == category1.id.to_s 
     find_value(last_response.body, "categoryName", ["member", "name", "value", "string"], 0).should == category1.category 
     
     find_value(last_response.body, "categoryId", ["member", "name", "value", "string"], 1).should == category2.id.to_s  
     find_value(last_response.body, "categoryName", ["member", "name", "value", "string"], 1).should == category2.category
   end
   
   it "should return correct response when the getPostCategories method is called with a movable type client" do
     for_post = TestDataHelper.valid_post
     
     post '/xmlrpc/',  "<methodCall>
                           <methodName>mt.getPostCategories</methodName>
                           <params>
                           <param><value><string>#{for_post.id}</string></value></param>
                           <param><value><string>#{@user.email}</string></value></param>
                           <param><value><string>password123</string></value></param>
                           </params>
                           </methodCall>"

     
     find_value(last_response.body, "categoryName", ["member", "name", "value", "string"], 0).should == for_post.categories[0].category 
     find_value(last_response.body, "categoryId", ["member", "name", "value", "string"], 0).should == for_post.categories[0].id.to_s
     
     find_value(last_response.body, "categoryName", ["member", "name", "value", "string"], 1).should == for_post.categories[1].category
     find_value(last_response.body, "categoryId", ["member", "name", "value", "string"], 1).should == for_post.categories[1].id.to_s
   end
   
   it "should update the post's categries when the setPostCategories method is called with a movable type client" do
     for_post = TestDataHelper.valid_post
     cat1 = TestDataHelper.category1
     cat2 = TestDataHelper.category2
     
     post '/xmlrpc/',  "<methodCall>
                         <methodName>mt.setPostCategories</methodName>
                         <params>
                           <param>
                             <value>
                       	<int>#{for_post.id}</int>
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
                       	<array>
                       	  <data>
                       	    <value>
                       	      <struct>
                       		<member>
                       		  <name>categoryId</name>
                       		  <value>
                       		    <int>#{cat1.id}</int>
                       		  </value>
                       		</member>
                       	      </struct>
                       	    </value>
                       	    <value>
                       	      <struct>
                       		<member>
                       		  <name>categoryId</name>
                       		  <value>
                       		    <int>#{cat2.id}</int>
                       		  </value>
                       		</member>
                       	      </struct>
                       	    </value>
                       	  </data>
                       	</array>
                             </value>
                           </param>
                         </params>
                       </methodCall>"

     for_post.reload
     for_post.categories[0].id.should == cat1.id
     for_post.categories[1].id.should == cat2.id
     
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
     
     last_response.body.should include("<boolean>1</boolean>")
   end
   
   
    it "should update the correct post and give the correct response when the editPost method is called using the blogger api" do

      post_to_update_id = @post.id
      old_post_slug = @post.slug
      id = TestDataHelper.category1.id
      id_1 = TestDataHelper.category2.id
        
      post '/xmlrpc/',  "<methodCall>
       <methodName>blogger.editPost</methodName>
       <params>
       <param>
        <value>
         <string>Irrel</string>
        </value>
       </param>
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
    				<string>&lt;title&gt;NEWYUPDATE-011&lt;/title&gt;&lt;category&gt;#{id},#{id_1}&lt;/category&gt;This is the body</string>
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
      post.title.should == "NEWYUPDATE-011"
      post.body.should == "This is the body"
      post.legacy_routes[0].slug.should == old_post_slug
      post.categories.count.should == 2
      post.tags.count.should == 2

    end
   
    it "should set a post to active when the publishPost method is called" do
      inactive_post = TestDataHelper.valid_post
      inactive_post.is_active = false
      inactive_post.save
      
      post '/xmlrpc/', "
      <methodCall>
      	<methodName>mt.publishPost</methodName>
      <params>
      <param><value><int>#{inactive_post.id}</int></value></param>
      <param><value><string>#{@user.email}</string></value></param>
      <param><value><string>password123</string></value></param>
      </params>
      </methodCall>"
      
      inactive_post.reload
      inactive_post.is_active.should be_true
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
      
      last_response.body.should include("<int>#{post.id}</int>")
    end
    
    it "should create a new post and give the correct response when the newPost method is called from a blogger client" do  
      
      id = TestDataHelper.category1.id
      id_1 = TestDataHelper.category2.id
      
      post '/xmlrpc/',  
      
      "<methodCall>
      	<methodName>blogger.newPost</methodName>
      	<params>
      		<param>
      			<value>
      				<string>Blog Name</string>
      			</value>
      		</param>
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
      				<string>&lt;title&gt;NEWY&lt;/title&gt;&lt;category&gt;#{id},#{id_1}&lt;/category&gt;This is the body</string>
      			</value>
      		</param>
      		<param>
      			<value>
      				<boolean>1</boolean>
      			</value>
      		</param>
      	</params>
      </methodCall>"
      
      post = Post.first(:title => "NEWY")
      post.title.should == "NEWY"
      post.body.should == "This is the body"
      post.categories.count.should == 2
      post.tags.count.should == 2
      post.month.should == DateTime.now.strftime("%B")
      post.year.should == DateTime.now.year
      post.is_active.should be_true
      
      last_response.body.should include("<int>#{post.id}</int>")
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
                       
  
     find_value(last_response.body, "page_id", ["member", "name", "value", "int"]).should == @page.id.to_s
     find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == @page.title
     find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == @page.body
     find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == @page.permalink
     #find_value(last_response.body, "mt_convert_breaks", ["member", "name", "value", "string"]).should == "__default__"
     find_value(last_response.body, "dateCreated", ["member", "name", "value",  "dateTime.iso8601"]).should == @page.created_at_iso8601
     #find_value(last_response.body, "page_parent_id", ["member", "name", "value", "string"]).should == 0.to_s
     
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
  
     find_value(last_response.body, "page_id", ["member", "name", "value", "int"]).should == @page.id.to_s
     find_value(last_response.body, "title", ["member", "name", "value", "string"]).should == @page.title
     find_value(last_response.body, "description", ["member", "name", "value", "string"]).should == @page.body
     find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == @page.permalink
     #find_value(last_response.body, "mt_convert_breaks", ["member", "name", "value", "string"]).should == "__default__"
     find_value(last_response.body, "dateCreated", ["member", "name", "value",  "dateTime.iso8601"]).should == @page.created_at_iso8601
     #find_value(last_response.body, "page_parent_id", ["member", "name", "value", "string"]).should == 0.to_s
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
     
     #The first one is the non valid page
     
     find_value(last_response.body, "page_id", ["member", "name", "value", "string"], 1).should == @page.id.to_s
     find_value(last_response.body, "page_title", ["member", "name", "value", "string"], 1).should == @page.title
     find_value(last_response.body, "page_parent_id", ["member", "name", "value", "string"], 1).should == "0"
     find_value(last_response.body, "dateCreated", ["member", "name", "value", "dateTime.iso8601"], 1).should == @page.created_at_iso8601
     find_value(last_response.body, "date_created_gmt", ["member", "name", "value", "dateTime.iso8601"], 1).should == @page.created_at_iso8601   
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
     last_response.body.should include("<string>#{page.id.to_s}</string>")
  
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
  
     find_value(last_response.body, "user_id", ["member", "name", "value", "string"]).should == @user.id.to_s
     find_value(last_response.body, "user_login", ["member", "name", "value", "string"]).should == @user.email
     find_value(last_response.body, "display_name", ["member", "name", "value", "string"]).should == @user.fullname
     find_value(last_response.body, "user_email", ["member", "name", "value", "string"]).should == @user.email
  
  
   end
    it "should return correct response when the getTags method is called" do
  
       tags = Tag.all
       
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
    
       find_value(last_response.body, "tag_id", ["member", "name", "value", "string"], 0).should == tags[0].id.to_s
       find_value(last_response.body, "name", ["member", "name", "value", "string"], 0).should == tags[0].tag
       find_value(last_response.body, "count", ["member", "name", "value", "string"], 0).should == tags[0].posts.count.to_s
       find_value(last_response.body, "slug", ["member", "name", "value", "string"], 0).should == tags[0].tag
       find_value(last_response.body, "html_url", ["member", "name", "value", "string"], 0).should == tags[0].permalink
       find_value(last_response.body, "rss_url", ["member", "name", "value", "string"], 0).should == ""
       
       find_value(last_response.body, "tag_id", ["member", "name", "value", "string"], 1).should == tags[1].id.to_s            
       find_value(last_response.body, "name", ["member", "name", "value", "string"], 1).should == tags[1].tag
       find_value(last_response.body, "count", ["member", "name", "value", "string"], 1).should == tags[1].posts.count.to_s   
       find_value(last_response.body, "slug", ["member", "name", "value", "string"], 1).should == tags[1].tag  
       find_value(last_response.body, "html_url", ["member", "name", "value", "string"], 1).should == tags[1].permalink 
       find_value(last_response.body, "rss_url", ["member", "name", "value", "string"], 1).should == ""           
     end
     
     it "should return the true when the edit tag method is called" do
      old_tag_name = Tag.first.tag
      post '/xmlrpc/', "<methodCall>
                        <methodName>shoutmouth.editTag</methodName>
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
                             <name>tag_id</name>
                             <value>
                              <string>#{Tag.first.id}</string>
                             </value>
                            </member>
                            <member>
                             <name>name</name>
                             <value>
                              <string>opencms</string>
                             </value>
                            </member>
                           </struct>
                           </value>
                          </param>
                         </params>
                        </methodCall>" 

         last_response.body.should include("<boolean>1</boolean>")
         tag = Tag.first
         tag.tag = old_tag_name
         tag.save
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
       last_response.body.should include("<int>#{category.id.to_s}</int>")

     end
     it "should edit the category when the editCategory method is called" do

       category = Category.first(:category => "Category - Metaweblog")
       
       post '/xmlrpc/', "<methodCall>
                        <methodName>shoutmouth.editCategory</methodName>
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
                             <name>category_id</name>
                             <value>
                              <string>#{category.id}</string>
                             </value>
                            </member>
                            <member>
                             <name>category</name>
                             <value>
                              <string>edit_category</string>
                             </value>
                            </member>
                            </struct>
                            </value>
                           </param>
                        </params>"
            category.reload
            category.category.should == "edit_category"
            last_response.body.should include("<boolean>1</boolean>")
            
            #tear down
            category.category = "Category - Metaweblog"
            category.save
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
       find_value(last_response.body, "total_comments", ["member", "name", "value", "int"]).should == "2"
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
       find_value(last_response.body, "software_name", ["member", "name", "value", "struct/member/name[text()='value']/../value/string"]).should == "Shout Mouth Blog Engine"
       find_value(last_response.body, "url", ["member", "name", "value", "struct/member/name[text()='value']/../value/string"]).should == Blog.url
       find_value(last_response.body, "site_name", ["member", "name", "value", "struct/member/name[text()='value']/../value/string"]).should == Blog.site_name
       find_value(last_response.body, "site_description", ["member", "name", "value", "struct/member/name[text()='value']/../value/string"]).should == Blog.site_description
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
       find_value(last_response.body, "post_id", ["member", "name", "value", "string"], 0).should == post_id.to_s
       find_value(last_response.body, "post_id", ["member", "name", "value", "string"], 1).should == post_id.to_s
       find_value(last_response.body, "post_id", ["member", "name", "value", "string"], 2).should == post_id.to_s
       lambda{ find_value(last_response.body, "post_id", ["member", "name", "value", "int"], 3)}.should raise_error
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
       find_value(last_response.body, "comment_id", ["member", "name", "value", "string"]).should == comment.id.to_s
       find_value(last_response.body, "parent", ["member", "name", "value", "string"]).should == "0"
       find_value(last_response.body, "link", ["member", "name", "value", "string"]).should == comment.post.permalink
       find_value(last_response.body, "post_id", ["member", "name", "value", "string"]).should == comment.post.id.to_s
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
     
     it "should add a comment the addComment method is called" do
       
       post = TestDataHelper.valid_post
       comment_count = post.comments.count
       
       post '/xmlrpc/',  "<methodCall>
       	<methodName>wp.newComment</methodName>
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
          <param>
    			<value>
     				<struct>
            <member>
							<name>author</name>
							<value>
								<string>dan@shout_mouth.com</string>
							</value>
						</member>
						<member>
							<name>content</name>
							<value>
								<string>Comment from metaweblog</string>
							</value>
						</member>
						<member>
							<name>author_email</name>
							<value>
								<string/>
							</value>
						</member>
						<member>
							<name>comment_parent</name>
							<value>
								<i4>0</i4>
							</value>
						</member>
						<member>
							<name>author_url</name>
							<value>
								<string/>
							</value>
						</member>
     				</struct>
     			</value>
     		</param>
       	</params>
       </methodCall>
       "
       
       post.comments.reload
       (comment_count + 1).should == post.comments.count
       
       
     end
 
  it "should edit a setting when the set option method is called" do
      post '/xmlrpc/', "<methodCall>
                  <methodName>wp.setOptions</methodName>
                  <params>
                  <param>
                    <value>
                      <string>1</string>
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
                          <name>footer_more_text</name>
                          <value>
                            <string>more more more</string>
                          </value>
                        </member>
                      </struct>
                    </value>
                  </param>
                </params>
              </methodCall>"

     Blog.footer_more_text.should == "more more more"
  end
  
  it "should add a user when the add user method is called" do
    post '/xmlrpc/', "<methodCall>
    <methodName>shoutmouth.addUser</methodName>
    <params>
      <param>
        <value>
          <string>1</string>
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
              <name>email</name>
              <value>
                <string>email@address.com</string>
              </value>
            </member>
            <member>
              <name>password</name>
              <value>
                <string>password</string>
              </value>
            </member>
            <member>
              <name>firstname</name>
              <value>
                <string>firstname</string>
              </value>
            </member>
            <member>
              <name>lastname</name>
              <value>
                <string>lastname</string>
              </value>
            </member>
          </struct>
        </value>
      </param>
    </params>
  </methodCall>"

  user = User.first(:email => "email@address.com")
  user.nil?.should be_false
  user.firstname.should == "firstname"
  user.lastname.should == "lastname"
  user.authenticate("password").should be_true

  end
  
  it "should edit a user when the editUser methods is called" do
    user = User.first(:email => "email@address.com")
    
    post '/xmlrpc/', "<methodCall>
                    <methodName>shoutmouth.editUser</methodName>
                    <params>
                      <param>
                        <value>
                          <string>1</string>
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
                              <name>user_id</name>
                              <value>
                                <string>#{user.id}</string>
                              </value>
                            </member>
                            <member>
                              <name>email</name>
                              <value>
                                <string>emailedit@address.com</string>
                              </value>
                            </member>
                            <member>
                              <name>password</name>
                              <value>
                                <string>passwordg</string>
                              </value>
                            </member>
                            <member>
                              <name>firstname</name>
                              <value>
                                <string>firstnameedit</string>
                              </value>
                            </member>
                            <member>
                              <name>lastname</name>
                              <value>
                                <string>lastnameedit</string>
                              </value>
                            </member>
                          </struct>
                        </value>
                      </param>
                    </params>
                  </methodCall>"

  user = User.first(:email => "emailedit@address.com")
  user.nil?.should be_false
  user.firstname.should == "firstnameedit"
  user.lastname.should == "lastnameedit"
  user.authenticate("passwordg").should be_true
  end
  
  it "should delete a user when the deleteUser methods is called" do
    user = User.first(:email => "emailedit@address.com")

    post '/xmlrpc/', "<methodCall>
      <methodName>shoutmouth.deleteUser</methodName>
      <params>
        <param>
          <value>
            <string>1</string>
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
            <i4>#{user.id}</i4>
          </value>
        </param>
      </params>
    </methodCall>"

    User.find_user("emailedit@address.com").should be_nil
  end

  private 
  def find_value(xml, find, hierarchy = [], nth = nil)
    return Nokogiri::XML(xml).xpath("//#{hierarchy[0]}/#{hierarchy[1]}[text()='#{find}']")[nth.nil? ? 0 : nth].parent.xpath("#{hierarchy[2]}/#{hierarchy[3]}").text
  end
  
end
