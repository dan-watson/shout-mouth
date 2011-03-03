require Dir.pwd + '/app/models/base/shout_record'

class Post
  include Shout::Record

  property :title, String, :length => 1000
  property :persisted_slug, String, :length => 1000
  property :body, Text
  property :is_page, Boolean, :default => false
  property :month, String
  property :year, Integer

  validates_presence_of :title, :body, :tags, :categories
  #validates_uniqueness_of :persisted_slug

  belongs_to  :user
  has n, :comments
  has n, :legacy_routes
  has n, :tags, :through => Resource
  has n, :categories, :through => Resource

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
    (created_at.midnight + Blog.comments_open_for_days) > DateTime.now.midnight
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
  
  def to_metaweblog
    {
      :postid => id,
      :dateCreated => created_at,
      :title => title,
      :description => body,
      :link => permalink,
      :wp_slug => slug,
      :mt_excerpt => "",
      :mt_allow_comments => "",
      :mt_keywords => readable_tags.gsub(" ", ""),
      :publish => is_active,
      :categories => categories.map{|category| category.category}
    }
  end

  def to_wordpress_page
    {
      :page_id => id,
      :title => title,
      :description => body,
      :link => permalink,
      :mt_convert_breaks => "__default__",
      :dateCreated => created_at,
      :page_parent_id => 0
    }
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

  def self.new_post_from_xmlrpc_payload xmlrpc_call
    post = Post.new(:title => xmlrpc_call[1][3]["title"],
    :body => xmlrpc_call[1][3]["description"],
    :user => User.find_user(xmlrpc_call[1][1]),
    :is_active => xmlrpc_call[1][4])
    
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
    
    post.category_posts.destroy
    post.add_categories(Category.categories_from_array(xmlrpc_call[1][3]["categories"]))
    
    post.post_tags.destroy
    xmlrpc_call[1][3]["mt_keywords"].nil? ? post.add_tags(Tag.tags_from_array(xmlrpc_call[1][3]["categories"])) : post.add_tags(Tag.tags_from_array(xmlrpc_call[1][3]["mt_keywords"].split(",")))
    
    post.is_active = xmlrpc_call[1][4]
    post.created_at = xmlrpc_call[1][3]["dateCreated"].to_time  unless xmlrpc_call[1][3]["dateCreated"].nil?
    
    post
  end

  def self.new_page_from_xmlrpc_payload xmlrpc_call
    post = Post.new(:title => xmlrpc_call[1][3]["title"],
    :body => xmlrpc_call[1][3]["description"],
    :user => User.find_user(xmlrpc_call[1][1]),
    :is_page => true,
    :is_active => xmlrpc_call[1][4])
    
    post.add_tag Tag.first_or_create({:tag => "page"}, {:tag => "page"})
    post.add_category Category.first_or_create({:category => "page"}, {:category => "page"})
    
    post
  end

  def self.edit_page_from_xmlrpc_payload xmlrpc_call
    page = Post.first(:id => xmlrpc_call[1][1])

    if(page.title != xmlrpc_call[1][4]["title"])
      page.add_legacy_route page.slug
    end

    page.title = xmlrpc_call[1][4]["title"]
    page.body = xmlrpc_call[1][4]["description"]
    page.is_active = xmlrpc_call[1][5]
    page
  end

  def self.mark_as_inactive post_id
    post = Post.get(post_id)
    post.is_active = false
    post.save
  end
end
