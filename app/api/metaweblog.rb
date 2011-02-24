module Metaweblog
  
  def new_media_object(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
      
      data = xmlrpc_call[1][3]
      
      
      name = data["name"].gsub(/\//,'')
      
      
      puts Blog.amazon_s3_key
      puts Blog.amazon_s3_secret_key
      
      AWS::S3::Base.establish_connection!(
                 :access_key_id     => Blog.amazon_s3_key, 
                 :secret_access_key => Blog.amazon_s3_secret_key
               )
       
      AWS::S3::S3Object.store(name, data["bits"], Blog.amazon_s3_bucket, :access => :public_read)
             
      XMLRPC::Marshal.dump_response({
            :file => name,
            :url => "#{Blog.amazon_s3_file_location}/#{Blog.amazon_s3_bucket}/#{name}"
      })
  end
  
  def new_post(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    post = Post.new(:title => xmlrpc_call[1][3]["title"], 
                    :body => xmlrpc_call[1][3]["description"], 
                    :tags => xmlrpc_call[1][3]["mt_keywords"].nil? ? xmlrpc_call[1][3]["categories"].join(",") : xmlrpc_call[1][3]["mt_keywords"],
                    :categories => xmlrpc_call[1][3]["categories"].join(","), 
                    :user => find_current_user(xmlrpc_call),
                    :is_active => xmlrpc_call[1][4])
                    
    return raise_xmlrpc_error(post.errors.full_messages.to_s) unless post.valid?
    
    post.save
    post.reload

    XMLRPC::Marshal.dump_response(post.id)
  end

  def edit_post(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
   
    post = Post.first(:id => xmlrpc_call[1][0])
    post.title = xmlrpc_call[1][3]["title"]
    post.body = xmlrpc_call[1][3]["description"]
    post.categories = xmlrpc_call[1][3]["categories"].join(",")
    post.tags = xmlrpc_call[1][3]["mt_keywords"].nil? ? xmlrpc_call[1][3]["categories"].join(",") : xmlrpc_call[1][3]["mt_keywords"]
    post.is_active = xmlrpc_call[1][4]
    post.created_at = xmlrpc_call[1][3]["dateCreated"].to_time  unless xmlrpc_call[1][3]["dateCreated"].nil?
    
    return raise_xmlrpc_error(post.errors.full_messages.to_s) unless post.valid?
    
    post.save
    post.reload

    XMLRPC::Marshal.dump_response(post.to_metaweblog)
  end
  
  def get_post(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
     post = Post.first(:id => xmlrpc_call[1][0])
     XMLRPC::Marshal.dump_response(post.to_metaweblog)
  end
  
  def get_categories(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    categories = []
    posts = Post.all_active.all(:is_page => false).each{|post| categories << post.categories}
    XMLRPC::Marshal.dump_response(categories.flatten.uniq.map{|c| {:description => c, :title => c}}) 
  end

  def get_recent_posts(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    posts = Post.all_active.all(:is_page => false, :limit => xmlrpc_call[1][3], :order => [:created_at.desc])
    XMLRPC::Marshal.dump_response(posts.map{|p| p.to_metaweblog})
  end
  
  def delete_post(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][2],xmlrpc_call[1][3])
     
     post = Post.get(xmlrpc_call[1][1])
     post.is_active = false
     post.save
     
     XMLRPC::Marshal.dump_response(true)
  end

  def get_users_blogs(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    XMLRPC::Marshal.dump_response(Blog.to_metaweblog)
   end
  
  def get_user_info(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    user = find_current_user(xmlrpc_call)
    XMLRPC::Marshal.dump_response(user.to_metaweblog)
  end
  
  #Wordpress API
  
  def get_page_list(xmlrpc_call)
      return raise_xmlrpc_error("Not Implemented")
  end
  
  def get_pages(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
     pages = Post.all_active.all(:is_page => true, :limit => xmlrpc_call[1][3], :order => [:created_at.desc])
     XMLRPC::Marshal.dump_response(pages.map{|p| p.to_wordpress_page})
  end
  
  def get_page(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][2],xmlrpc_call[1][3])
    page = Post.first(:id => xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(page.to_wordpress_page)
  end
  
  def edit_page(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][2],xmlrpc_call[1][3])
    page = Post.first(:id => xmlrpc_call[1][1])
    page.title = xmlrpc_call[1][4]["title"]
    page.body = xmlrpc_call[1][4]["description"]
    page.is_active = xmlrpc_call[1][5]
    
    return raise_xmlrpc_error(page.errors.full_messages.to_s) unless page.valid?
    
    page.save
    XMLRPC::Marshal.dump_response(true)
  end
  
  def delete_page(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
     page = Post.first(:id => xmlrpc_call[1][3])
     page.is_active = false
     page.save
     XMLRPC::Marshal.dump_response(true)
  end
  
  def new_page(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    page = Post.new(:title => xmlrpc_call[1][3]["title"], 
                    :body => xmlrpc_call[1][3]["description"], 
                    :tags => "page", 
                    :categories => "page", 
                    :user => find_current_user(xmlrpc_call[1][1]),
                    :is_page => true,
                    :is_active => xmlrpc_call[1][4])
                    
    return raise_xmlrpc_error(page.errors.full_messages.to_s) unless page.valid?

    page.save
    page.reload

    XMLRPC::Marshal.dump_response(page.id)
  end
  
  def get_authors(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    users = [] << find_current_user(xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(users.map{|u| u.to_wordpress_author})
  end
  
  def get_tags(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    tags = []
    Post.all_active.all(:is_page => false).each{|post| tags << post.tags}
    XMLRPC::Marshal.dump_response(tags.flatten.uniq.sort.map{|t| {:name => t}})
  end

  #General Methods
  def authenticated?(email, password)
    user = find_current_user(email)
    if user
      user.authenticate(password)
    else
      false
    end
  end
  
  def find_current_user(email)
      User.find(:email => email).first
  end
  
  def raise_xmlrpc_error(message)  
    "<methodResponse>
      <fault>
        <value>
          <struct>
            <member>
              <name>faultCode</name>
              <value><int>40003</int></value>
            </member>
            <member>
              <name>faultString</name>
              <value><string>#{message}</string></value>
          </member>
        </struct>
      </value>
    </fault>
    </methodResponse>"
  end
  
end