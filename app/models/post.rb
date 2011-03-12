require Dir.pwd + '/app/models/base/shout_record'

class Post
  include Shout::Record

  property :title, String, :length => 1000
  property :persisted_slug, String, :length => 1000
  property :body, Text, :lazy => false
  property :is_page, Boolean, :default => false
  property :month, String
  property :year, Integer

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
  
  def to_metaweblog
    {
      :dateCreated => created_at,
      :userid => user.id.to_s,
      :postid => id.to_s,
      :description => body,
      :title => title,
      :link => permalink,
      :permaLink => permalink,
      :categories => categories.map{|category| category.category},
      :mt_excerpt => "",
      :mt_text_more => "",
      :mt_allow_comments => 1,
      :mt_allow_pings => 0,
      :mt_keywords => readable_tags.gsub(" ", ""),
      :wp_slug => slug,
      :wp_password => "",
      :wp_author_id => user.id.to_s,
      :wp_author_display_name => user.fullname,
      :date_created_gmt => created_at,
      :post_status => PostStatus.status_from_boolean(is_active),
      :custom_fields => [
                          {
                            :id => "2",
                            :key => "_edit_last",
                            :value => user.id.to_s
        
                          },
                          {
                            :id => "1",
                            :key => "_edit_lock",
                            :value => "#1299280582:#{user.id.to_s}"
                          }
                        ],
      :wp_post_format => "standard"
      #:publish => is_active
    }
  end

  def to_wordpress_page
    {
      :dateCreated => created_at,
      :userid => user.id.to_s,
      :page_id => id,
      :page_status =>  PostStatus.status_from_boolean(is_active),
      :description => body,
      :title => title,
      :link => permalink,
      :permaLink => permalink,
      :categories => [],#categories.map{|category| category.category},
      :excerpt => "",
      :text_more => "",
      :mt_allow_comments => 0,
      :mt_allow_pings => 0,
      :wp_slug => slug,
      :wp_password => "",
      :wp_author => user.email,
      :wp_page_parent_id => 0,
      :wp_page_parent_title => "",
      :wp_page_order => 0,
      :wp_author_id => user.id.to_s,
      :wp_author_display_name => user.fullname, #possible need to be email,
      :date_created_gmt => created_at,
      #:mt_convert_breaks => "__default__",
      #:page_parent_id => "0",
      :custom_fields => [
        {
          :id => "13",
          :key => "localDraftUniqueID",
          :value => slug

        }
      ],
      :wp_page_template => "default"
        
    }
  end
  
  
  
  def to_minimal_wordpress_page
    {
      :page_id => id.to_s,
      :page_title => title,
      :page_parent_id => "0",
      :dateCreated => created_at,
      :date_created_gmt => created_at
    }
  end
  
  def to_wordpress_comment_count
    {
      :approved => comments.all_active_and_ham.count,
      :awaiting_moderation => 0, #comments are auto-moderated with askimet
      :spam => comments.all_active_and_spam.count,
      :total_comments => comments.all_active.count
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
    post = Post.new(:title => xmlrpc_call[1][3]["title"],
    :body => xmlrpc_call[1][3]["description"],
    :user => User.find_user(xmlrpc_call[1][1]),
    :is_page => true)
    
    if xmlrpc_call[1][3]["page_status"].nil?
      post.is_active = xmlrpc_call[1][4]
    else
      post.is_active = PostStatus.boolean_from_status(xmlrpc_call[1][3]["page_status"])
    end
    
    post.add_tag Tag.first_or_create({:tag => "page"}, {:tag => "page"})
    post.add_category Category.first_or_create({:category => "page"}, {:category => "page"})
    
    post
  end

  def self.edit_page_from_xmlrpc_payload xmlrpc_call
    page = Post.first(:id => xmlrpc_call[1][1])

    if(page.title != xmlrpc_call[1][4]["title"])
      page.add_legacy_route page.slug
    end
    
    if xmlrpc_call[1][4]["page_status"].nil?
      page.is_active = xmlrpc_call[1][5]
    else
      post.is_active = PostStatus.boolean_from_status(xmlrpc_call[1][4]["page_status"])
    end

    page.title = xmlrpc_call[1][4]["title"]
    page.body = xmlrpc_call[1][4]["description"]
    
    page
  end

  def self.mark_as_inactive post_id
    post = Post.get(post_id)
    post.is_active = false
    post.save
  end
end
