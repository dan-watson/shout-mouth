require_relative 'base'

class Post < Base
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