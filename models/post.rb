require_relative 'base'

class Post < Base
  include DataMapper::Resource
  
      property :id, Serial
      property :title, String
      property :body, Text
      property :created_at, DateTime
      property :is_active, Boolean
      
      validates_presence_of :title, :body
      
      belongs_to  :user
      has n, :comments
      
      def initialize(attributes = nil)
         super(attributes)

          if new?
            self.is_active = true
            self.created_at = DateTime.now
          end
      end
end