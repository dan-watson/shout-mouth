require_relative 'base'

class Post
  include Base
    
    property :title, String
    property :body, Text
  
    validates_presence_of :title, :body
  
    belongs_to  :user
    has n, :comments
end