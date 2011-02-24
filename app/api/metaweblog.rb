module Metaweblog
  
  def new_media_object(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
      
      data = xmlrpc_call[1][3]
      name = data["name"].gsub(/\//,'')
      
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
    post = Post.new_post_from_xmlrpc_payload(xmlrpc_call)
    return raise_xmlrpc_error(post.errors.full_messages.to_s) unless post.valid?
    
    post.save
    post.reload

    XMLRPC::Marshal.dump_response(post.id)
  end

  def edit_post(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    post = Post.edit_post_from_xmlrpc_payload(xmlrpc_call)
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
    XMLRPC::Marshal.dump_response(Category.all_categories.map{|c| {:description => c, :title => c}}) 
  end

  def get_recent_posts(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    posts = Post.all_active_posts.all(:limit => xmlrpc_call[1][3])
    XMLRPC::Marshal.dump_response(posts.map{|p| p.to_metaweblog})
  end
  
  def delete_post(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][2],xmlrpc_call[1][3])
     Post.mark_as_inactive(xmlrpc_call[1][1])
     XMLRPC::Marshal.dump_response(true)
  end

  def get_users_blogs(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    XMLRPC::Marshal.dump_response(Blog.to_metaweblog)
   end
  
  def get_user_info(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    user = User.find_user(xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(user.to_metaweblog)
  end
  
  #Wordpress API
  
  def get_page_list(xmlrpc_call)
      return raise_xmlrpc_error("Not Implemented")
  end
  
  def get_pages(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
     pages = Post.all_active_pages.all(:limit => xmlrpc_call[1][3])
     XMLRPC::Marshal.dump_response(pages.map{|p| p.to_wordpress_page})
  end
  
  def get_page(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][2],xmlrpc_call[1][3])
    page = Post.first(:id => xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(page.to_wordpress_page)
  end
  
  def edit_page(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][2],xmlrpc_call[1][3])
    page = Post.edit_page_from_xmlrpc_payload(xmlrpc_call)
    return raise_xmlrpc_error(page.errors.full_messages.to_s) unless page.valid?
    
    page.save
    
    XMLRPC::Marshal.dump_response(true)
  end
  
  def delete_page(xmlrpc_call)
     return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
     Post.mark_as_inactive(xmlrpc_call[1][3])
     XMLRPC::Marshal.dump_response(true)
  end
  
  def new_page(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    page = Post.new_page_from_xmlrpc_payload(xmlrpc_call)
    return raise_xmlrpc_error(page.errors.full_messages.to_s) unless page.valid?

    page.save
    page.reload

    XMLRPC::Marshal.dump_response(page.id)
  end
  
  def get_authors(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    users = [] << User.find_user(xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(users.map{|u| u.to_wordpress_author})
  end
  
  def get_tags(xmlrpc_call)
    return raise_xmlrpc_error("User credentials supplied are incorrect") unless authenticated?(xmlrpc_call[1][1],xmlrpc_call[1][2])
    XMLRPC::Marshal.dump_response(Tag.all_tags.map{|t| {:name => t}})
  end

  #General Methods
  def authenticated?(email, password)
    user = User.find_user(email)
    if user
      user.authenticate(password)
    else
      false
    end
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