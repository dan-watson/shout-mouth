require_relative 'base/shout_record'

require 'factory_girl'

class Post
  include Shout::Record
    
    property :title, String
    property :body, Text
    property :is_page, Boolean, :default => false
    property :tags, CommaSeparatedList
    property :categories, CommaSeparatedList
    
    validates_presence_of :title, :body, :tags, :categories
  
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
    
end

