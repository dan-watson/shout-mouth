require Dir.pwd + '/app/models/base/shout_record'

class Post
  include Shout::Record

  property :title, String, :length => 1000
  property :persisted_slug, String, :length => 1000
  property :body, Text, :lazy => false
  property :is_page, Boolean, :default => false
  property :month, String
  property :year, Integer
  property :local_draft_id, String, :length => 200, :default => ""

  validates_presence_of :title, :body, :tags, :categories
  validates_uniqueness_of :title

  belongs_to  :user
  has n, :comments
  has n, :legacy_routes
  has n, :tags, :through => Resource, :is_active => true
  has n, :categories, :through => Resource, :is_active => true

  def author
    user.fullname
  end

  def readable_tags
    tags.map{|tag| tag.tag}.join(", ")
  end

  def readable_categories
    categories.map{|category| category.category}.join(", ")
  end

  def readable_date
    created_at.to_date.strftime("%A, #{created_at.day.ordinalize} %B, %Y")
  end

  def url_date
    created_at.to_date.strftime("%Y/%m/%d")
  end

  def slug
    #a slug is a URL-safe string that echoes the title
    #in this method we want to remove any weird punctuation and spaces
    slug = title.gsub(/[^a-zA-Z0-9 ]/,"").downcase
    slug = slug.gsub(/[ ]+/," ")
    slug = slug.gsub(/ /,"-")

    slug
  end

  def permalink
    return "#{Blog.url}/post/#{url_date}/#{slug}" unless is_page?
    "#{Blog.url}/page/#{slug}"
  end

  def allow_comments?
    return true if Blog.comments_open_for_days == 0
    (created_at.to_date.to_datetime + Blog.comments_open_for_days) > DateTime.now.to_date.to_datetime
  end

  def add_legacy_route legacy_url
    legacy_routes << LegacyRoute.new(:slug => legacy_url)
  end
  
  def add_category category
    categories << category
  end
  
  def add_categories collection
    collection.each{|category| categories << category}
  end
  
  def add_tag tag
    tags << tag
  end
  
  def add_tags collection
    collection.each{|tag| tags << tag}
  end
  
  def add_comment_from_xmlrpc_payload xmlrpc_call
  
    data = xmlrpc_call[1][4]
    user = User.first(:email => data["author"])
    comment = Comment.new(:post => self, 
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

  before :save do
    self.persisted_slug = self.slug
    self.month = created_at.strftime("%B")
    self.year = created_at.year
  end

  def self.month_year_counter
    all_active_posts.group_by{|post| "#{post.year}-#{post.month}"}
  end

  def self.all_active_posts
    all_active.all(:is_page => false)
  end

  def self.all_active_pages
    all_active.all(:is_page => true)
  end

  def self.new_post_from_xmlrpc_payload_blogger_client xmlrpc_call
    
    title = xmlrpc_call[1][4].gsub(/<title>(.+?)<\/title>/).first.gsub(/<?(.)title>/,"")
    cataegory_ids = xmlrpc_call[1][4].gsub(/<category>(.+?)<\/category>/).first.gsub(/<?(.)category>/,"").split(",")
    body = xmlrpc_call[1][4].gsub(/<(.+?)>(.+?)<(.+?)>/, "")
    is_active = xmlrpc_call[1][5]
    
    post = Post.new(:title => title,
    :body => body,
    :user => User.find_user(xmlrpc_call[1][2]),
    :is_active => is_active)
    
    cataegory_ids.each{|id| post.categories << Category.get(id)}
    post.categories.each{|category| post.tags << Tag.first_or_create({:tag => category.category}, {:tag => category.category})}
    
    post
    
  end
  
  def self.edit_post_from_xmlrpc_payload_blogger_client xmlrpc_call
     post = Post.get(xmlrpc_call[1][1])

     title = xmlrpc_call[1][4].gsub(/<title>(.+?)<\/title>/).first.gsub(/<?(.)title>/,"")
     
     if(post.title != title)
       post.add_legacy_route post.slug
     end

     post.title = title
     post.body = xmlrpc_call[1][4].gsub(/<(.+?)>(.+?)<(.+?)>/, "")

     cataegory_ids = xmlrpc_call[1][4].gsub(/<category>(.+?)<\/category>/).first.gsub(/<?(.)category>/,"").split(",")
     
     post.categories
     post.category_posts.destroy
     cataegory_ids.each{|id| post.categories << Category.get(id)}
     
     post.tags
     post.post_tags.destroy
     post.categories.each{|category| post.tags << Tag.first_or_create({:tag => category.category}, {:tag => category.category})}
     
     post.is_active = xmlrpc_call[1][5]
     post
  end
  
  def self.set_post_categories_from_xmlrpc_payload xmlrpc_call
    post = Post.get(xmlrpc_call[1][0])
    
    categories = xmlrpc_call[1][3]
    
    post.categories
    post.category_posts.destroy
    categories.each{|category| post.categories << Category.get(category["categoryId"])}
    
    post.save
  end
  
  def self.new_post_from_xmlrpc_payload xmlrpc_call
  
    post = Post.new(:title => xmlrpc_call[1][3]["title"],
    :body => xmlrpc_call[1][3]["description"],
    :user => User.find_user(xmlrpc_call[1][1]))
    
    if xmlrpc_call[1][3]["post_status"].nil?
      post.is_active = xmlrpc_call[1][4]
    else
      post.is_active = PostStatus.boolean_from_status(xmlrpc_call[1][3]["post_status"])
    end
    
    xmlrpc_call[1][3]["mt_keywords"].nil? ? post.add_tags(Tag.tags_from_array(xmlrpc_call[1][3]["categories"])) : post.add_tags(Tag.tags_from_array(xmlrpc_call[1][3]["mt_keywords"].split(",")))
    post.add_categories(Category.categories_from_array(xmlrpc_call[1][3]["categories"]))
    
    post
  end

  def self.edit_post_from_xmlrpc_payload xmlrpc_call
    post = Post.first(:id => xmlrpc_call[1][0])

    if(post.title != xmlrpc_call[1][3]["title"])
      post.add_legacy_route post.slug
    end
    
    post.title = xmlrpc_call[1][3]["title"]
    post.body = xmlrpc_call[1][3]["description"]
    
    post.categories
    post.category_posts.destroy
    post.add_categories(Category.categories_from_array(xmlrpc_call[1][3]["categories"]))
    
    post.tags
    post.post_tags.destroy
    xmlrpc_call[1][3]["mt_keywords"].nil? ? post.add_tags(Tag.tags_from_array(xmlrpc_call[1][3]["categories"])) : post.add_tags(Tag.tags_from_array(xmlrpc_call[1][3]["mt_keywords"].split(",")))
    
    if xmlrpc_call[1][3]["post_status"].nil?
      post.is_active = xmlrpc_call[1][4]
    else
      post.is_active = PostStatus.boolean_from_status(xmlrpc_call[1][3]["post_status"])
    end
    
    post.created_at = xmlrpc_call[1][3]["dateCreated"].to_time  unless xmlrpc_call[1][3]["dateCreated"].nil?
    
    post
  end

  def self.new_page_from_xmlrpc_payload xmlrpc_call

    #Some clients use the new method to update a page!
    
    #if id does not exist in payload then use title else use id
    
    pages = Post.all(:id => xmlrpc_call[1][3]["postid"]) | Post.all(:title => xmlrpc_call[1][3]["title"], :is_page => true)
    page = pages.first.nil? ? Post.new : pages.first
    
    page.is_page = true    
    page.id = nil if page.new?
    page.local_draft_id = xmlrpc_call[1][3]["custom_fields"].nil? ? "" : xmlrpc_call[1][3]["custom_fields"][0]["value"]
    
    if(page.title != xmlrpc_call[1][3]["title"] && !page.new?)
      page.add_legacy_route page.slug
    end
    
    page.title = xmlrpc_call[1][3]["title"]
    page.body = xmlrpc_call[1][3]["description"]
    page.user = User.find_user(xmlrpc_call[1][1])
    
    
    if xmlrpc_call[1][3]["page_status"].nil?
      page.is_active = xmlrpc_call[1][4]
    else
      page.is_active = PostStatus.boolean_from_status(xmlrpc_call[1][3]["page_status"])
    end
    
    page.add_tag Tag.first_or_create({:tag => "page"}, {:tag => "page"})
    page.add_category Category.first_or_create({:category => "page"}, {:category => "page"})
    
    page
  end

  def self.edit_page_from_xmlrpc_payload xmlrpc_call
    page = Post.first(:id => xmlrpc_call[1][1])

    if(page.title != xmlrpc_call[1][4]["title"])
      page.add_legacy_route page.slug
    end
    
    if xmlrpc_call[1][4]["page_status"].nil?
      page.is_active = xmlrpc_call[1][5]
    else
      page.is_active = PostStatus.boolean_from_status(xmlrpc_call[1][4]["page_status"])
    end

    page.title = xmlrpc_call[1][4]["title"]
    page.body = xmlrpc_call[1][4]["description"]
    page.local_draft_id = xmlrpc_call[1][4]["custom_fields"].nil? ? "" : xmlrpc_call[1][4]["custom_fields"][0]["value"]
    
    page
  end
  
  def self.mark_as_active post_id
    post = Post.get(post_id)
    post.is_active = true
    post.save
  end

  def self.mark_as_inactive post_id
    post = Post.get(post_id)
    post.is_active = false
    post.save
  end
end
