require_relative 'base'

class Comment < Base
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