require Dir.pwd + '/app/api/amazon_s3/amazon_s3'
require Dir.pwd + '/app/api/upload/upload'
require Dir.pwd + '/app/api/metaweblog/strategies/authentication_details'
require Dir.pwd + '/app/api/metaweblog/presenters/presenters'
require Dir.pwd + '/app/api/metaweblog/mappers/mappers'


module Metaweblog

  #alias method for wordpress
  def upload_file(xmlrpc_call)
    new_media_object(xmlrpc_call)
  end

  def new_media_object(xmlrpc_call)
    data = xmlrpc_call[1][3]
    name = data["name"].gsub(/\//,'')
    plain_name = data["name"]
    bits = data["bits"]

    return Upload.save_file(plain_name, bits) if Blog.use_file_based_storage

    AmazonS3.save_file(name, bits)
  end

  def new_post(xmlrpc_call)
        
    if(client_from(xmlrpc_call) == BLOGGER)
      post = PostMapper.new(xmlrpc_call).new_post_from_xmlrpc_payload_blogger_client
      return raise_xmlrpc_error(4003, post.errors.full_messages.to_s) unless post.save
      return post.id 
    end
    
    post = PostMapper.new(xmlrpc_call).new_post_from_xmlrpc_payload
    return raise_xmlrpc_error(4003, post.errors.full_messages.to_s) unless post.save
    post.id
  end

  def edit_post(xmlrpc_call)
    if(client_from(xmlrpc_call) == BLOGGER)
      post = PostMapper.new(xmlrpc_call).edit_post_from_xmlrpc_payload_blogger_client
      return raise_xmlrpc_error(4003, post.errors.full_messages.to_s) unless post.save
      return true
    end
    
    post = PostMapper.new(xmlrpc_call).edit_post_from_xmlrpc_payload
    return raise_xmlrpc_error(4003, post.errors.full_messages.to_s) unless post.save
    #PostPresenter.new(post.reload).to_metaweblog
    return true
  end
  
  def publish_post(xmlrpc_call)
    #return a boolean - wordpress returns the id - should be ok as it is part of the mt specs.
    Post.mark_as_active(xmlrpc_call[1][0])
  end

  def get_post(xmlrpc_call) 
    client = client_from(xmlrpc_call)
    id = 0
    
    case
      when client == BLOGGER
        id = xmlrpc_call[1][1]
      else
        id = xmlrpc_call[1][0]
    end

    post = Post.first(:id => id)
    
    return PostPresenter.new(post).to_blogger if client == BLOGGER
    PostPresenter.new(post).to_metaweblog
  end

  def get_categories(xmlrpc_call)
    Category.all(:category.not => "page").map{|category| CategoryPresenter.new(category).to_metaweblog}
  end
  
  def get_post_categories(xmlrpc_call)
    Post.get(xmlrpc_call[1][0]).categories.map{|category| CategoryPresenter.new(category).to_movable_type_post_category}
  end
  
  def set_post_categories(xmlrpc_call)
    PostMapper.new(xmlrpc_call).set_post_categories_from_xmlrpc_payload
  end

  def get_recent_posts(xmlrpc_call)
    
    client = client_from(xmlrpc_call)
    limit = 0
    
    case
      when client == BLOGGER
          limit = xmlrpc_call[1][4] 
      else
          limit = xmlrpc_call[1][3] 
    end
    
    #Some clients pass limit as 0 for all posts
    limit == 0 ? posts = Post.all(:is_page => false, :order => [ :created_at.desc ]) : posts = Post.all(:is_page => false, :order => [ :created_at.desc ], :limit => limit)
    
    return posts.map{|p| PostPresenter.new(p).to_blogger} if client == BLOGGER
    posts.map{|p| PostPresenter.new(p).to_metaweblog}
  end
  
  def get_recent_post_titles(xmlrpc_call)
    xmlrpc_call[1][3].nil? ? limit = 0 : limit = xmlrpc_call[1][3]
    
    posts =  Post.all(:is_page => false, :order => [ :created_at.desc ])
    
    if(limit > 0)
      posts = posts.all(:limit => limit)
    end
    
    posts.map{|post| PostPresenter.new(post).to_movable_type}
  end

  def delete_post(xmlrpc_call)
    Post.mark_as_inactive(xmlrpc_call[1][1])
    true
  end

  def get_users_blogs(xmlrpc_call)
    BlogPresenter.new(Blog).to_metaweblog
  end

  def get_user_info(xmlrpc_call)
    user = User.find_user(xmlrpc_call[1][1])
    UserPresenter.new(user).to_metaweblog
  end

  def set_template(xmlrpc_call)
    raise_xmlrpc_error(401, "Sorry, this user cannot edit the template.")
  end
  
  def get_template(xmlrpc_call)
    raise_xmlrpc_error(401, "Sorry, this user cannot edit the template.")
  end

  def get_page_list(xmlrpc_call)
    pages = Post.all(:is_page => true)
    pages.map{|p| PostPresenter.new(p).to_minimal_wordpress_page}
  end

  def get_pages(xmlrpc_call)
    pages = Post.all(:is_page => true, :limit => xmlrpc_call[1][3] || 100000)
    pages.map{|p| PostPresenter.new(p).to_wordpress_page}
  end

  def get_page(xmlrpc_call)
    page = Post.first(:id => xmlrpc_call[1][1])
    PostPresenter.new(page).to_wordpress_page
  end

  def edit_page(xmlrpc_call)
    page = PostMapper.new(xmlrpc_call).edit_page_from_xmlrpc_payload
    return raise_xmlrpc_error(4003, page.errors.full_messages.to_s) unless page.save
    true
  end

  def delete_page(xmlrpc_call)
    Post.mark_as_inactive(xmlrpc_call[1][3])
    true
  end

  def new_page(xmlrpc_call)
    page = PostMapper.new(xmlrpc_call).new_page_from_xmlrpc_payload
    return raise_xmlrpc_error(4003, page.errors.full_messages.to_s) unless page.save
    page.id.to_s
  end

  def get_authors(xmlrpc_call)
    users = User.all_active
    users.map{|u| UserPresenter.new(u).to_wordpress_author}
  end

  def add_user(xmlrpc_call)
    user = UserMapper.new(xmlrpc_call).new_user_from_xmlrpc_payload
    return raise_xmlrpc_error(4003, user.errors.full_messages.to_s) unless user.save
    true  
  end

  def edit_user(xmlrpc_call)
    user = UserMapper.new(xmlrpc_call).edit_user_from_xmlrpc_payload
    return raise_xmlrpc_error(4003, user.errors.full_messages.to_s) unless user.save
    true
  end

  def delete_user(xmlrpc_call)
    return UserMapper.new(xmlrpc_call).delete_user_from_xmlrpc_payload
  end

  def get_tags(xmlrpc_call)
    Tag.all.map{|tag| TagPresenter.new(tag).to_metaweblog}
  end
  
  def edit_tag(xmlrpc_call)
    tag = TagMapper.new(xmlrpc_call).edit_tag_from_xmlrpc_payload
    return raise_xmlrpc_error(4003, tag.errors.full_messages.to_s) unless tag.save
    true
  end

  def new_category(xmlrpc_call)
    category = CategoryMapper.new(xmlrpc_call).new_category_from_xmlrpc_payload
    category.id
  end
  
  def edit_category(xmlrpc_call)
    category = CategoryMapper.new(xmlrpc_call).edit_category_from_xmlrpc_payload
    return raise_xmlrpc_error(4003, category.errors.full_messages.to_s) unless category.save
    true
  end

  def delete_category(xmlrpc_call)
    CategoryMapper.new(xmlrpc_call).mark_as_inactive_from_xmlrpc_payload
  end
  
  def suggest_categories(xmlrpc_call)
    Category.all(:category.not => "page", :category.like => "%#{xmlrpc_call[1][3]}%", :limit => xmlrpc_call[1][4]).map{|category| CategoryPresenter.new(category).to_minimal_metaweblog}
  end
  
  def get_category_list(xmlrpc_call)
    Category.all(:category.not => "page").map{|category| CategoryPresenter.new(category).to_movable_type_category_list_item}
  end
  
  def get_comment_count(xmlrpc_call)
     id = xmlrpc_call[1][3].to_i
     unless id == 0
      post = Post.first(:id => id)
      return PostPresenter.new(post).to_wordpress_comment_count
     end
     return CommentsPresenter.new(Comment.all).to_wordpress_comment_count   
  end
  
  def get_post_status_list(xmlrpc_call)
    PostStatus.statuses
  end
  
  def get_page_status_list(xmlrpc_call)
    PostStatus.statuses
  end
  
  def get_page_templates(xmlrpc_call)
    {:Default => "default"}
  end
  
  def get_options(xmlrpc_call)
   BlogPresenter.new(Blog).to_wordpress_options
  end
  
  def set_options(xmlrpc_call)
    settings = BlogMapper.new(xmlrpc_call).update_settings 
    BlogPresenter.new(Blog).to_wordpress_options_subset(settings)
  end
  
  def get_comment(xmlrpc_call)
    comment = Comment.first(:id => xmlrpc_call[1][3])
    CommentPresenter.new(comment).to_wordpress_comment
  end
  
  def get_comments(xmlrpc_call)
    comments = CommentMapper.new(xmlrpc_call).load_comments_from_xmlrpc_payload
    comments.map{|comment| CommentPresenter.new(comment).to_wordpress_comment}
  end
  
  def get_comment_status_list(xmlrpc_call)
    CommentPresenter.comment_status_list
  end
  
  def delete_comment(xmlrpc_call)
    Comment.mark_comment_as_inactive(xmlrpc_call[1][3])
    true
  end
  
  def edit_comment(xmlrpc_call)
    comment = CommentMapper.new(xmlrpc_call).edit_comment_from_xmlrpc_payload
    return raise_xmlrpc_error(4003, comment.errors.full_messages.to_s) unless comment.save
    true
  end
  
  def new_comment(xmlrpc_call)    
    post = Post.get(xmlrpc_call[1][3])
    comment = PostMapper.new(xmlrpc_call).add_comment_from_xmlrpc_payload_for(post)
    return raise_xmlrpc_error(4003, comment.errors.full_messages.to_s) unless comment.save
    comment.id
  end
  
  def get_post_formats(xmlrpc_call)
    {:standard => "Standard"}
  end
  
  def get_media_library(xmlrpc_call)
    raise_xmlrpc_error(4003, "Shout Mouth Message - Not Implemented")
  end
  
  def get_media_item(xmlrpc_call)
    raise_xmlrpc_error(4003, "Shout Mouth Message - Not Implemented")
  end

  def say_hello(xmlrpc_call)
    "Hello!"
  end
  
  def add_two_numbers(xmlrpc_call)
    xmlrpc_call[1][0].to_i + xmlrpc_call[1][1].to_i
  end
  
  
  def supported_text_filters(xmlrpc_call)
    [] #same as wp - return empty array
  end
  
  def get_trackback_pings(xmlrpc_call)
    [] #dont support trackbacks so return empty array
  end
  
  def get_pingbacks(xmlrpc_call)
    [] #dont support trackbacks so return empty array
  end
  
  def ping(xmlrpc_call)
    #dont support pings so just return a nice response - same as wordpress
    link_from = xmlrpc_call[1][0] #external url
    link_to = xmlrpc_call[1][1] #post
    
    puts xmlrpc_call[1][0]
    "Pingback from #{link_from} to #{link_to} registered. Keep the web talking! :-)"
  end
  
  def multicall(xmlrpc_call)
    call_list = xmlrpc_call[1..-1][0][0]
    
    response = []
    call_list.each{|method_call|
                method_name = method_call["methodName"]
                                params = method_call["params"]
                                method = method_name.gsub(/(.*)\.(.*)/, '\2').gsub(/([A-Z])/, '_\1').downcase
                                
                                call = [method_name, params]
                                
                                authentication_details = authentication_details_from(method, call)
                                array_holder = []
                                array_holder << send(method, call) if authenticated?(authentication_details)
                                response << array_holder
              }
              response
              
  end
  
  def dump_response(data)
    response = XMLRPC::Marshal.dump_response(data)
    #Wordpress Sends The Response with slight differences....
    
    response.gsub("<i4>", "<int>")
            .gsub("</i4>", "</int>")
            .gsub("<string/>", "<string></string>")
  end

  def raise_xmlrpc_error(code, message)
    {
      :fault => {
        :faultCode => code,
        :faultString => message
      }
    }
  end
  
  def does_not_need_authentication?(method)
    ["list_methods",
      "get_capabilities", 
      "multicall", 
      "say_hello", 
      "add_two_numbers", 
      "supported_methods", 
      "supported_text_filters", 
      "get_trackback_pings",
      "get_pingbacks",
      "ping"].include?(method)
  end
  
  def get_capabilities(xmlrpc_call)
    {
        :xmlrpc => {
          :specUrl => "http://www.xmlrpc.com/spec",
          :specVersion => 1
        },
        :faults_interop => {
          :specUrl => "http://xmlrpc-epi.sourceforge.net/specs/rfc.fault_codes.php",
          :specVersion => 20010516
        },
        :'system.multicall' => {
          :specUrl => "http://www.xmlrpc.com/discuss/msgReader$1208",
          :specVersion => 1
        } 
        
      }
  end
  
  def supported_methods(xmlrpc_call)
    list_methods(xmlrpc_call).reverse
  end

  def list_methods(xmlrpc_call)
    methods =["system.multicall",
    "system.listMethods",
    "system.getCapabilities",
    "demo.addTwoNumbers",
    "demo.sayHello",
    "pingback.extensions.getPingbacks",
    "pingback.ping",
    "mt.publishPost",
    "mt.getTrackbackPings",
    "mt.supportedTextFilters",
    "mt.supportedMethods",
    "mt.setPostCategories",
    "mt.getPostCategories",
    "mt.getRecentPostTitles",
    "mt.getCategoryList",
    "metaWeblog.getUsersBlogs",
    "metaWeblog.setTemplate", 
    "metaWeblog.getTemplate", #NOT IMPLEMENTED
    "metaWeblog.deletePost",
    "metaWeblog.newMediaObject",
    "metaWeblog.getCategories",
    "metaWeblog.getRecentPosts",
    "metaWeblog.getPost",
    "metaWeblog.editPost",
    "metaWeblog.newPost",
    "blogger.deletePost",
    "blogger.editPost",
    "blogger.newPost",
    "blogger.setTemplate", #NOT IMPLEMENTED
    "blogger.getTemplate", #NOT IMPLEMENTED
    "blogger.getRecentPosts",
    "blogger.getPost",
    "blogger.getUserInfo",
    "blogger.getUsersBlogs",
    "wp.getPostFormats",
    "wp.getMediaLibrary", # NOT IMPLEMENTED
    "wp.getMediaItem", # NOT IMPLEMENTED
    "wp.getCommentStatusList",
    "wp.newComment",
    "wp.editComment",
    "wp.deleteComment",
    "wp.getComments",
    "wp.getComment",
    "wp.setOptions",
    "wp.getOptions",
    "wp.getPageTemplates",
    "wp.getPageStatusList",
    "wp.getPostStatusList",
    "wp.getCommentCount",
    "wp.uploadFile",
    "wp.suggestCategories",
    "wp.deleteCategory",
    "wp.newCategory",
    "wp.getTags",
    "wp.getCategories",
    "wp.getAuthors",
    "wp.getPageList",
    "wp.editPage",
    "wp.deletePage",
    "wp.newPage",
    "wp.getPages",
    "wp.getPage",
    "wp.getUsersBlogs",
    "shoutmouth.editTag",
    "shoutmouth.editCategory",
    "shoutmouth.addUser",
    "shoutmouth.editUser",
    "shoutmouth.deleteUser"]
    
    methods
  end

  def authentication_details_from(method, xmlrpc_call)
      Object::const_get("#{client_from(xmlrpc_call)}Strategy").new.authentication_details_from(method, xmlrpc_call)
  end
  
  def authenticated?(authentication_details)
    user = User.find_user(authentication_details[:username])
    if user
      user.authenticate(authentication_details[:password])
    else
      false
    end
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
