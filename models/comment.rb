require_relative 'base/shout_record'

class Comment
  include Shout::Record
  
    property :comment, Text
    property :email, String

    validates_presence_of :comment
    validates_format_of :email, :as => :email_address
  
    belongs_to :post
end