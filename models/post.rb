require_relative 'base/shout_record'

class Post
  include Shout::Record
    
    property :title, String
    property :body, Text
  
    validates_presence_of :title, :body
  
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
    
end