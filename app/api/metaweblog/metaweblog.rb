require Dir.pwd + '/app/api/amazon_s3/amazon_s3'
require Dir.pwd + '/app/api/metaweblog/strategies/authentication_details'

module Metaweblog

  #alias method for wordpress
  def upload_file(xmlrpc_call)
    new_media_object(xmlrpc_call)
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
    return raise_xmlrpc_error(4003, post.errors.full_messages.to_s) unless post.save
    XMLRPC::Marshal.dump_response(post.id)
  end

  def edit_post(xmlrpc_call)
    post = Post.edit_post_from_xmlrpc_payload(xmlrpc_call)
    return raise_xmlrpc_error(4003, post.errors.full_messages.to_s) unless post.save
    XMLRPC::Marshal.dump_response(post.reload.to_metaweblog)
  end

  def get_post(xmlrpc_call)
    post = Post.first(:id => xmlrpc_call[1][0])
    XMLRPC::Marshal.dump_response(post.to_metaweblog)
  end

  def get_categories(xmlrpc_call)
    XMLRPC::Marshal.dump_response(Category.usable_active_categories.map{|category| category.to_metaweblog})
  end

  def get_recent_posts(xmlrpc_call)
    limit = xmlrpc_call[1][3] 
    #Some clients pass limit as 0 for all posts
    limit == 0 ? posts = Post.all_active_posts : posts = Post.all_active_posts.all(:limit => limit)
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
    pages = Post.all_active_pages.all
    XMLRPC::Marshal.dump_response(pages.map{|p| p.to_minimal_wordpress_page})
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
    return raise_xmlrpc_error(4003, page.errors.full_messages.to_s) unless page.save
    XMLRPC::Marshal.dump_response(true)
  end

  def delete_page(xmlrpc_call)
    Post.mark_as_inactive(xmlrpc_call[1][3])
    XMLRPC::Marshal.dump_response(true)
  end

  def new_page(xmlrpc_call)
    page = Post.new_page_from_xmlrpc_payload(xmlrpc_call)
    return raise_xmlrpc_error(4003, page.errors.full_messages.to_s) unless page.save
    XMLRPC::Marshal.dump_response(page.id)
  end

  def get_authors(xmlrpc_call)
    users = [] << User.find_user(xmlrpc_call[1][1])
    XMLRPC::Marshal.dump_response(users.map{|u| u.to_wordpress_author})
  end

  def get_tags(xmlrpc_call)
    XMLRPC::Marshal.dump_response(Tag.usable_active_tags.map{|tag| tag.to_metaweblog})
  end
  
  def new_category(xmlrpc_call)
    category = Category.new_category_from_xmlrpc_payload(xmlrpc_call)
    XMLRPC::Marshal.dump_response(category.id)
  end
  
  def delete_category(xmlrpc_call)
    success = Category.mark_as_inactive_from_xmlrpc_payload(xmlrpc_call)
    XMLRPC::Marshal.dump_response(success)
  end
  
  def suggest_categories(xmlrpc_call)
    XMLRPC::Marshal.dump_response(Category.usable_active_categories.all(:category.like => "%#{xmlrpc_call[1][3]}%", :limit => xmlrpc_call[1][4]).map{|category| category.to_minimal_metaweblog})
  end
  
  def get_comment_count(xmlrpc_call)
     post = Post.first(:id => xmlrpc_call[1][3].to_i)
     XMLRPC::Marshal.dump_response(post.to_wordpress_comment_count)
  end
  
  def get_post_status_list(xmlrpc_call)
    #OK - Wordpress returns a list of draft, pending, private, publish
    #We will return just publish at the moment as there is currently no functionality for the other constants
    # Method will not have a test as it really does not need it!
    XMLRPC::Marshal.dump_response({:publish => "Published"})
  end
  
  def get_page_status_list(xmlrpc_call)
    #OK - Wordpress returns a list of draft, private, publish
    #We will return just publish at the moment as there is currently no functionality for the other constants
    # Method will not have a test as it really does not need it!
    XMLRPC::Marshal.dump_response({:publish => "Published"})
  end
  
  def get_page_templates(xmlrpc_call)
    #Shout Mouth does not support per page templating as wordpress does just return the default preview for a post
    # Method will not have a test as it really does not need it!
    XMLRPC::Marshal.dump_response({:WebPreview => "webpreview.html"})
  end
  
  def get_options(xmlrpc_call)
    XMLRPC::Marshal.dump_response(Blog.to_wordpress_options)
  end
  
  def set_options(xmlrpc_call)
    #INPUT
    # int blog_id
    # string username
    # string password
    #   array
    #     struct
    #       string name
    #       string value
    #OUTPUT
    # array
    #   struct
    #     string option
    #     string value
    # WILL IMPLEMENT IN NEXT VERSION - WILL USE A KEY/VALUE STORE FOR OPTIONS 
    return raise_xmlrpc_error(4003, "Options cannot be set for Shout Mouth blogs via the client api. Please update your /config/config.yaml file.")
  end
  
  def get_comment(xmlrpc_call)
    comment = Comment.first(:id => xmlrpc_call[1][3])
    XMLRPC::Marshal.dump_response(comment.to_wordpress_comment)
  end
  
  #OK SERIOUSLY - This is not part of any api spec but seems to be part of wordpress
  #Some clients use this method to check the system is responding - not testing this method.
  def say_hello(xmlrpc_call)
    XMLRPC::Marshal.dump_response("Hello!")
  end
  
  #OK SERIOUSLY - This is not part of any api spec but seems to be part of wordpress
  #Some clients use this method to check the system is responding - not testing this method.
  def add_two_numbers(xmlrpc_call)
    total = xmlrpc_call[1][0].to_i + xmlrpc_call[1][1].to_i
    XMLRPC::Marshal.dump_response(total)
  end

  def raise_xmlrpc_error(code, message)
    "<methodResponse>
    <fault>
    <value>
    <struct>
    <member>
    <name>faultCode</name>
    <value><int>#{code.to_s}</int></value>
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
  
  def does_not_need_authentication?(method)
    ["list_methods", "say_hello", "add_two_numbers"].include?(method)
  end

  def list_methods(xmlrpc_call)
    methods = [ 
      "demo.sayHello",
      "demo.addTwoNumbers",
      "system.listMethods",
      "metaWeblog.newMediaObject",
      "metaWeblog.newPost",
      "metaWeblog.editPost",
      "metaWeblog.getPost",
      "metaWeblog.getCategories",
      "metaWeblog.getRecentPosts",
      "metaWeblog.deletePost",
      "metaWeblog.getUsersBlogs",
      "blogger.getUserInfo",
      "wp.setOptions", #NOT IMPLEMENTED IN THIS VERSION - NEXT VERSION WILL SUPPORT DYNAMIC SITE CONFIGURATION
      "wp.getOptions",
      "wp.getPageTemplates",
      "wp.getPageStatusList",
      "wp.getPostStatusList",
      "wp.getCommentCount",
      "wp.uploadFile",
      "wp.suggestCategories",
      "wp.deleteCategory",
      "wp.newCategory",
      "wp.getPageList",
      "wp.getPages",
      "wp.getPage",
      "wp.editPage",
      "wp.deletePage",
      "wp.newPage",
      "wp.getCategories",
      "wp.getAuthors",
      "wp.getTags"]
    # LIST OF ALL API METHODS - LONG ARGGGHHHH!! LETS GO
    # system.listMethods - IMPLEMENTED
    # demo.addTwoNumbers - IMPLEMENTED
    # demo.sayHello - IMPLEMENTED
    # pingback.extensions.getPingbacks
    # pingback.ping
    # mt.publishPost
    # mt.getTrackbackPings
    # mt.supportedTextFilters
    # mt.supportedMethods
    # mt.setPostCategories
    # mt.getPostCategories
    # mt.getRecentPostTitles
    # mt.getCategoryList
    # metaWeblog.getUsersBlogs - IMPLEMENTED
    # metaWeblog.setTemplate
    # metaWeblog.getTemplate
    # metaWeblog.deletePost - IMPLEMENTED
    # metaWeblog.newMediaObject - IMPLEMENTED
    # metaWeblog.getCategories - IMPLEMENTED
    # metaWeblog.getRecentPosts - IMPLEMENTED
    # metaWeblog.getPost - IMPLEMENTED
    # metaWeblog.editPost - IMPLEMENTED
    # metaWeblog.newPost - IMPLEMENTED
    # blogger.deletePost
    # blogger.editPost
    # blogger.newPost
    # blogger.setTemplate
    # blogger.getTemplate
    # blogger.getRecentPosts
    # blogger.getPost
    # blogger.getUserInfo - IMPLEMENTED
    # blogger.getUsersBlogs - IMPLEMENTED
    # wp.getPostFormats
    # wp.getMediaLibrary
    # wp.getMediaItem
    # wp.getCommentStatusList
    # wp.newComment
    # wp.editComment
    # wp.deleteComment
    # wp.getComments
    # wp.getComment
    # wp.setOptions - NOT GOING TO IMPLEMENT AT THIS TIME
    # wp.getOptions - IMPLEMENTED
    # wp.getPageTemplates - IMPLEMENTED
    # wp.getPageStatusList - IMPLEMENTED
    # wp.getPostStatusList - IMPLEMENTED
    # wp.getCommentCount - IMPLEMENTED
    # wp.uploadFile - IMPLEMENTED
    # wp.suggestCategories - IMPLEMENTED
    # wp.deleteCategory - IMPLEMENTED
    # wp.newCategory - IMPLEMENTED
    # wp.getTags - IMPLEMENTED
    # wp.getCategories - IMPLEMENTED
    # wp.getAuthors - IMPLEMENTED
    # wp.getPageList - IMPLEMENTED
    # wp.editPage - IMPLEMENTED
    # wp.deletePage - IMPLEMENTED
    # wp.newPage - IMPLEMENTED
    # wp.getPages - IMPLEMENTED
    # wp.getPage -IMPLEMENTED
    # wp.getUsersBlogs - IMPLEMENTED
    
    XMLRPC::Marshal.dump_response(methods)
  end

  #OK the metaweblog / workpress api sucks a little. For some reason only known to hindu cows... Different methods payloads will supply the
  #username and password in different positions in the xml structure - values are not named and can only be obtained
  #by position - needed to pull in different stratergy's for different clients

  def authentication_details_from(method, xmlrpc_call)
      Class.class_eval("#{client_from(xmlrpc_call)}Strategy").new.authentication_details_from(method, xmlrpc_call)
  end
  

  WORDPRESS = "Wordpress"
  BLOGGER = "Blogger"
  METAWEBLOG = "Metaweblog"
  
  def client_from(xmlrpc_call)
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
