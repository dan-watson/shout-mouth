DataMapper.setup(:default, "sqlite:///#{File.dirname(__FILE__)}/shout_mouth.db")

require 'dm-validations'

class Post
  include DataMapper::Resource
  
      property :id, Serial
      property :title, String
      property :body, Text
      property :created_at, DateTime
      property :active, Boolean
      
      validates_presence_of :title, :body
      
      belongs_to  :user
      has n, :comments
end

class Comment
  include DataMapper::Resource
  
  property :id, Serial
  property :comment, Text
  property :email, String
  property :created_at, DateTime
  property :active, Boolean
  
  validates_presence_of :comment
  validates_format_of :email, :as => :email_address
  
  belongs_to :post
end

class User
    include DataMapper::Resource
    
    property :id, Serial
    property :email, String
    property :password, String
    property :salt, String
    property :is_active, Boolean
    property :created_at, DateTime
    
    validates_presence_of :email, :password
    validates_format_of :email, :as => :email_address
    
    has n, :posts
end