require_relative 'base/shout_record'

class Post
  include Shout::Record
    
    property :title, String
    property :body, Text
  
    validates_presence_of :title, :body
  
    belongs_to  :user
    has n, :comments
end