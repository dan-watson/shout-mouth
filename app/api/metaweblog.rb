require Dir.pwd + '/app/api/amazon_s3'
module Metaweblog

  def does_not_need_authentication?(method)
    ["list_methods"].include?(method)
  end

  def list_methods(xmlrpc_call)
    methods = [ "system.listMethods",
      "metaWeblog.newMediaObject",
      "metaWeblog.newPost",
      "metaWeblog.editPost",
      "metaWeblog.getPost",
      "metaWeblog.getCategories",
      "metaWeblog.getRecentPosts",
      "metaWeblog.deletePost",
      "metaWeblog.getUsersBlogs",
      "blogger.getUserInfo",
      "wp.getPageList",
      "wp.getPages",
      "wp.getPage",
      "wp.editPage",
      "wp.deletePage",
      "wp.newPage",
      "wp.getAuthors",
    "wp.getTags"]
    XMLRPC::Marshal.dump_response(methods)
  end

  def new_media_object(xmlrpc_call)
    data = xmlrpc_call[1][3]
    name = data["name"].gsub(/\//,'')

    AmazonS3.save_file(name, data["bits"])

    XMLRPC::Marshal.dump_response({
      :file => name,
      :url => "#{Blog.amazon_s3_file_location}#{Blog.amazon_s3_bucket}/#{name}"
    })
  end

  def new_post(xmlrpc_call)
    post = Post.new_post_from_xmlrpc_payload(xmlrpc_call)
    return raise_xmlrpc_error(post.errors.full_messages.to_s) unless post.save
    XMLRPC::Marshal.dump_response(post.id)
  end

  def edit_post(xmlrpc_call)
    post = Post.edit_post_from_xmlrpc_payload(xmlrpc_call)
    return raise_xmlrpc_error(post.errors.full_messages.to_s) unless post.save
    XMLRPC::Marshal.dump_response(post.reload.to_metaweblog)
  end

  def get_post(xmlrpc_call)
    post = Post.first(:id => xmlrpc_call[1][0])
    XMLRPC::Marshal.dump_response(post.to_metaweblog)
  end

  def get_categories(xmlrpc_call)
    XMLRPC::Marshal.dump_response(Category.usable_active_categories.map{|category| {:description => category.category, :title => category.category}})
  end

  def get_recent_posts(xmlrpc_call)
    posts = Post.all_active_posts.all(:limit => xmlrpc_call[1][3])
    XMLRPC::Marshal.dump_response(posts.map{|p| p.to_metaweblog})
  end

  def delete_post(xmlrpc_call)
    Post.mark_as_inactive(xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(true)
  end

  def get_users_blogs(xmlrpc_call)
    XMLRPC::Marshal.dump_response(Blog.to_metaweblog)
  end

  def get_user_info(xmlrpc_call)
    user = User.find_user(xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(user.to_metaweblog)
  end

  #Wordpress API

  def get_page_list(xmlrpc_call)
    return raise_xmlrpc_error("Not Implemented")
  end

  def get_pages(xmlrpc_call)
    pages = Post.all_active_pages.all(:limit => xmlrpc_call[1][3])
    XMLRPC::Marshal.dump_response(pages.map{|p| p.to_wordpress_page})
  end

  def get_page(xmlrpc_call)
    page = Post.first(:id => xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(page.to_wordpress_page)
  end

  def edit_page(xmlrpc_call)
    page = Post.edit_page_from_xmlrpc_payload(xmlrpc_call)
    return raise_xmlrpc_error(page.errors.full_messages.to_s) unless page.save
    XMLRPC::Marshal.dump_response(true)
  end

  def delete_page(xmlrpc_call)
    Post.mark_as_inactive(xmlrpc_call[1][3])
    XMLRPC::Marshal.dump_response(true)
  end

  def new_page(xmlrpc_call)
    page = Post.new_page_from_xmlrpc_payload(xmlrpc_call)
    return raise_xmlrpc_error(page.errors.full_messages.to_s) unless page.save
    XMLRPC::Marshal.dump_response(page.id)
  end

  def get_authors(xmlrpc_call)
    users = [] << User.find_user(xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(users.map{|u| u.to_wordpress_author})
  end

  def get_tags(xmlrpc_call)
    XMLRPC::Marshal.dump_response(Tag.usable_active_tags.map{|tag| {:name => tag.tag}})
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

  #OK the metaweblog / workpress api sucks a little. For some reason only known to hindu cows... Different methods payloads will supply the
  #username and password in different positions in the xml structure - values are not named and can only be obtained
  #by position - method below could be a seperate factory or even a stratergy to throw at the authenticate method.
  #YAGNI - this will do!

  WORDPRESS = "WORDPRESS"
  BLOGGER = "BLOGGER"
  METAWEBLOG = "METAWEBLOG"

  def authentication_details_lookup(method, xmlrpc_call)

    #exception to the rule
    if (client_call(xmlrpc_call) == WORDPRESS && method == "get_users_blogs")
      return {:username => xmlrpc_call[1][0], :password => xmlrpc_call[1][1]}
    end

    case method
    when "delete_post", "get_page", "edit_page"
      {:username => xmlrpc_call[1][2], :password => xmlrpc_call[1][3]}
    else
      {:username => xmlrpc_call[1][1], :password => xmlrpc_call[1][2]}
    end
  end

  def client_call(xmlrpc_call)
    case xmlrpc_call[0].split(".")[0]
    when "wp"
      WORDPRESS
    when "blogger"
      BLOGGER
    else "metaWeblog"
      METAWEBLOG
    end
  end

end
