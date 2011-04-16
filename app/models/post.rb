require Dir.pwd + '/app/models/base/shout_record'

class Post
  include Shout::Record
  include Sinatra::Cache::Helpers
  
  property :title, String, :length => 1000
  property :persisted_slug, String, :length => 1000
  property :body, Text, :lazy => false
  property :is_page, Boolean, :default => false
  property :month, String
  property :year, Integer
  property :local_draft_id, String, :length => 200, :default => ""
  property :page_order, Integer, :default => 0
  property :parent_page_id, Integer, :default => 0

  validates_presence_of :title, :body, :tags, :categories
  validates_uniqueness_of :title

  belongs_to  :user
  has n, :comments
  has n, :legacy_routes
  has n, :tags, :through => Resource, :is_active => true
  has n, :categories, :through => Resource, :is_active => true
  
  before :save do
    self.persisted_slug = self.slug
    self.month = created_at.strftime("%B")
    self.year = created_at.year
    invalidate_cache
  end
  
  def parent_page
    Post.get(parent_page_id)
  end
  
  def child_pages
    Post.all(:parent_page_id => id, :is_active => true, :order => [:page_order.asc])
  end

  #Instance Methods
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
  
  
  def invalidate_cache
    puts "here"
    puts settings.cache_enabled
    #Remove page / post cache
    cache_expire(link)
    #Remove tag cache
    tags.each{|tag| cache_expire(tag.link)}
    #Remove archive cache
    cache_expire('/archive')
    #Remove rss cache
    cache_expire('/rss')
    #Remove category cache
    categories.each{|category| cache_expire(category.link)}
    #Remove date cache
    cache_expire("/posts/date/#{month}-#{year}")
    #Remove index cache
    cache_expire('/index')
  end

  def permalink
    "#{Blog.url}#{link}"
  end
  
  def link
    return "/post/#{url_date}/#{slug}" unless is_page?
    "/page/#{slug}"
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

  #Factory Methods Output
  def self.month_year_counter
    all_active_posts.group_by{|post| "#{post.year}-#{post.month}"}
  end

  def self.all_active_posts
    #Get all posts published created before now.... this allows queueing of future posts.
    all_active.all(:is_page => false, :created_at.lte => Time.now)
  end

  def self.all_active_pages
    all_active.all(:is_page => true)
  end
  
  def self.all_active_posts_and_pages
    all_active_posts.union(all_active_pages)
  end

  #Factory Methods Input
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
