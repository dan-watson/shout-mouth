require_relative 'base/shout_record'

require 'akismetor'

class Comment
  include Shout::Record
  
    property :comment_author, String
    property :comment_author_email, String
    property :comment_content, Text
    property :comment_author_url, String
    property :user_ip, String
    property :user_agent, Text
    property :referrer, String
    property :is_spam, Boolean
    
    validates_presence_of :comment_author, :comment_author_email, :comment_content, :comment_author_url
    validates_format_of :email, :as => :comment_author_email
  
    belongs_to :post
    
    def spam?       
        comment_attributes = {
          :key => Blog.akismet_key,  #Grab From Config
          :blog => Blog.url, #Grab From Config
          :user_ip => user_ip,
          :user_agent => user_agent, 
          :referrer => referrer,
          :permalink => post.permalink,
          :comment_type => 'comment',
          :comment_author => comment_author,
          :comment_author_email => comment_author_email,
          :comment_author_url => comment_author_url,
          :comment_content => comment_content
        }
        Akismetor.spam?(comment_attributes)
    end
   
    before :save do
       self.is_spam = spam?
    end
end
