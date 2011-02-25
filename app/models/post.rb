require_relative 'base/shout_record'

require 'factory_girl'

class Post
  include Shout::Record
    
    property :title, String
    property :persisted_slug, String
    property :body, Text
    property :is_page, Boolean, :default => false
    property :tags, CommaSeparatedList
    property :categories, CommaSeparatedList
    
    validates_presence_of :title, :body, :tags, :categories
    #validates_uniqueness_of :persisted_slug
  
    belongs_to  :user
    has n, :comments
    has n, :legacy_routes
    
    def slug
      #a slug is a URL-safe string that echoes the title
      #in this method we want to remove any weird punctuation and spaces
      slug = title.gsub(/[^a-zA-Z0-9 ]/,"").downcase
      slug = slug.gsub(/[ ]+/," ")
      slug = slug.gsub(/ /,"-")

      slug
    end
    
    def permalink
         "#{Blog.url}/post/#{url_date}/#{slug}"
    end
    
    def url_date
        created_at.to_date.strftime("%Y/%m/%d")
    end
    
    def add_legacy_route legacy_url
        legacy_routes << LegacyRoute.new(:slug => legacy_url)
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
        :mt_keywords => tags.join(","),
        :publish => is_active,
        :categories => categories
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
    end
    
    def self.all_active_posts
      all_active.all(:is_page => false)
    end
    
    def self.all_active_pages
      all_active.all(:is_page => true)
    end
    
    def self.new_post_from_xmlrpc_payload xmlrpc_call
      Post.new(:title => xmlrpc_call[1][3]["title"], 
                      :body => xmlrpc_call[1][3]["description"], 
                      :tags => xmlrpc_call[1][3]["mt_keywords"].nil? ? xmlrpc_call[1][3]["categories"].join(",") : xmlrpc_call[1][3]["mt_keywords"],
                      :categories => xmlrpc_call[1][3]["categories"].join(","), 
                      :user => User.find_user(xmlrpc_call[1][1]),
                      :is_active => xmlrpc_call[1][4])
    end
    
    def self.edit_post_from_xmlrpc_payload xmlrpc_call
      post = Post.first(:id => xmlrpc_call[1][0])
      
      if(post.title != xmlrpc_call[1][3]["title"])
        post.add_legacy_route post.slug
      end
      
      post.title = xmlrpc_call[1][3]["title"]
      post.body = xmlrpc_call[1][3]["description"]
      post.categories = xmlrpc_call[1][3]["categories"].join(",")
      post.tags = xmlrpc_call[1][3]["mt_keywords"].nil? ? xmlrpc_call[1][3]["categories"].join(",") : xmlrpc_call[1][3]["mt_keywords"]
      post.is_active = xmlrpc_call[1][4]
      post.created_at = xmlrpc_call[1][3]["dateCreated"].to_time  unless xmlrpc_call[1][3]["dateCreated"].nil?
      post
    end
  
    def self.mark_as_inactive post_id
       post = Post.get(post_id)
       post.is_active = false
       post.save
    end
    
    def self.new_page_from_xmlrpc_payload xmlrpc_call
      Post.new(:title => xmlrpc_call[1][3]["title"], 
                      :body => xmlrpc_call[1][3]["description"], 
                      :tags => "page", 
                      :categories => "page", 
                      :user => User.find_user(xmlrpc_call[1][1]),
                      :is_page => true,
                      :is_active => xmlrpc_call[1][4])
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
end

