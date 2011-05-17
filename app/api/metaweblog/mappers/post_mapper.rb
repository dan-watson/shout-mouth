class PostMapper
  
  def initialize(xmlrpc_call)
    @xmlrpc_call = xmlrpc_call
  end
  
  def new_post_from_xmlrpc_payload_blogger_client
    
    title = @xmlrpc_call[1][4].gsub(/<title>(.+?)<\/title>/).first.gsub(/<?(.)title>/,"")
    cataegory_ids = @xmlrpc_call[1][4].gsub(/<category>(.+?)<\/category>/).first.gsub(/<?(.)category>/,"").split(",")
    body = @xmlrpc_call[1][4].gsub(/<(.+?)>(.+?)<(.+?)>/, "")
    is_active = @xmlrpc_call[1][5]
    
    post = Post.new(:title => title,
    :body => body,
    :user => User.find_user(@xmlrpc_call[1][2]),
    :is_active => is_active)
    
    cataegory_ids.each{|id| post.categories << Category.get(id)}
    post.categories.each{|category| post.tags << Tag.first_or_create({:tag => category.category}, {:tag => category.category})}
    
    post
    
  end
  
  def new_post_from_xmlrpc_payload
  
    post = Post.new(:title => @xmlrpc_call[1][3]["title"],
    :body => @xmlrpc_call[1][3]["description"],
    :user => User.find_user(@xmlrpc_call[1][1]))
    
    if @xmlrpc_call[1][3]["post_status"].nil?
      post.is_active = @xmlrpc_call[1][4]
    else
      post.is_active = PostStatus.boolean_from_status(@xmlrpc_call[1][3]["post_status"])
    end
    
    if !@xmlrpc_call[1][3]["dateCreated"].nil?
      post.created_at = @xmlrpc_call[1][3]["dateCreated"].to_time
    end
    
    @xmlrpc_call[1][3]["mt_keywords"].nil? ? post.add_tags(Tag.tags_from_array(@xmlrpc_call[1][3]["categories"])) : post.add_tags(Tag.tags_from_array(@xmlrpc_call[1][3]["mt_keywords"].split(",")))
    post.add_categories(Category.categories_from_array(@xmlrpc_call[1][3]["categories"]))
    
    post
  end
  
  def edit_post_from_xmlrpc_payload_blogger_client
     post = Post.get(@xmlrpc_call[1][1])

     title = @xmlrpc_call[1][4].gsub(/<title>(.+?)<\/title>/).first.gsub(/<?(.)title>/,"")
     
     if(post.title != title)
       post.add_legacy_route post.slug
     end

     post.title = title
     post.body = @xmlrpc_call[1][4].gsub(/<(.+?)>(.+?)<(.+?)>/, "")

     cataegory_ids = @xmlrpc_call[1][4].gsub(/<category>(.+?)<\/category>/).first.gsub(/<?(.)category>/,"").split(",")
     
     post.categories
     post.category_posts.destroy
     cataegory_ids.each{|id| post.categories << Category.get(id)}
     
     post.tags
     post.post_tags.destroy
     post.categories.each{|category| post.tags << Tag.first_or_create({:tag => category.category}, {:tag => category.category})}
     
     post.is_active = @xmlrpc_call[1][5]
     post
  end
  
  
  def edit_post_from_xmlrpc_payload
    post = Post.first(:id => @xmlrpc_call[1][0])

    if(post.title != @xmlrpc_call[1][3]["title"])
      post.add_legacy_route post.slug
    end
    
    post.title = @xmlrpc_call[1][3]["title"]
    post.body = @xmlrpc_call[1][3]["description"]
    
    post.categories
    post.category_posts.destroy
    post.add_categories(Category.categories_from_array(@xmlrpc_call[1][3]["categories"]))
    
    post.tags
    post.post_tags.destroy
    @xmlrpc_call[1][3]["mt_keywords"].nil? ? post.add_tags(Tag.tags_from_array(@xmlrpc_call[1][3]["categories"])) : post.add_tags(Tag.tags_from_array(@xmlrpc_call[1][3]["mt_keywords"].split(",")))
    
    if @xmlrpc_call[1][3]["post_status"].nil?
      post.is_active = @xmlrpc_call[1][4]
    else
      post.is_active = PostStatus.boolean_from_status(@xmlrpc_call[1][3]["post_status"])
    end
    
    post.created_at = @xmlrpc_call[1][3]["dateCreated"].to_time  unless @xmlrpc_call[1][3]["dateCreated"].nil?
    
    post
  end
  
  def set_post_categories_from_xmlrpc_payload
    post = Post.get(@xmlrpc_call[1][0])
    
    categories = @xmlrpc_call[1][3]
    
    post.categories
    post.category_posts.destroy
    categories.each{|category| post.categories << Category.get(category["categoryId"])}
    
    post.save
  end
  
  def edit_page_from_xmlrpc_payload
    page = Post.first(:id => @xmlrpc_call[1][1])

    if(page.title != @xmlrpc_call[1][4]["title"])
      page.add_legacy_route page.slug
    end
    
    if @xmlrpc_call[1][4]["page_status"].nil?
      page.is_active = @xmlrpc_call[1][5]
    else
      page.is_active = PostStatus.boolean_from_status(@xmlrpc_call[1][4]["page_status"])
    end

    page.title = @xmlrpc_call[1][4]["title"]
    page.body = @xmlrpc_call[1][4]["description"]
    page.local_draft_id = @xmlrpc_call[1][4]["custom_fields"].nil? ? "" : @xmlrpc_call[1][4]["custom_fields"][0]["value"]
    
    page
  end
  
  def new_page_from_xmlrpc_payload

    #Some clients use the new method to update a page!
    
    #if id does not exist in payload then use title else use id
    
    pages = Post.all(:id => @xmlrpc_call[1][3]["postid"]) | Post.all(:title => @xmlrpc_call[1][3]["title"], :is_page => true)
    page = pages.first.nil? ? Post.new : pages.first
    
    page.is_page = true    
    page.id = nil if page.new?
    page.local_draft_id = @xmlrpc_call[1][3]["custom_fields"].nil? ? "" : @xmlrpc_call[1][3]["custom_fields"][0]["value"]
    
    if(page.title != @xmlrpc_call[1][3]["title"] && !page.new?)
      page.add_legacy_route page.slug
    end
    
    page.title = @xmlrpc_call[1][3]["title"]
    page.body = @xmlrpc_call[1][3]["description"]
    page.user = User.find_user(@xmlrpc_call[1][1])
    
    
    if @xmlrpc_call[1][3]["page_status"].nil?
      page.is_active = @xmlrpc_call[1][4]
    else
      page.is_active = PostStatus.boolean_from_status(@xmlrpc_call[1][3]["page_status"])
    end
    
    page.add_tag Tag.first_or_create({:tag => "page"}, {:tag => "page"})
    page.add_category Category.first_or_create({:category => "page"}, {:category => "page"})
    
    #wp_page_order - int
    page.page_order = @xmlrpc_call[1][3]["wp_page_order"] unless @xmlrpc_call[1][3]["wp_page_order"].nil?
    
    #wp_page_parent_id - int
    page.parent_page_id = @xmlrpc_call[1][3]["wp_page_parent_id"] unless @xmlrpc_call[1][3]["wp_page_parent_id"].nil?
    
    
    page
  end
  
  def add_comment_from_xmlrpc_payload_for post
  
    data = @xmlrpc_call[1][4]
    user = User.first(:email => data["author"])
    comment = Comment.new(:post => post, 
                :comment_author => user.fullname, 
                :comment_author_email => user.email, 
                :comment_content => data["content"],
                :comment_author_url => Blog.url,
                :user_ip => "N/A",
                :user_agent => "BLOGGING CLIENT",
                :referrer => "N/A",
                :is_spam => false)
    comment
    
  end
  
end
