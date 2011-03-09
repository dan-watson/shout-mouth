require Dir.pwd + '/app/models/base/shout_record'

require 'akismetor'
require 'digest/md5'

class Comment
  include Shout::Record

  property :comment_author, String
  property :comment_author_email, String
  property :comment_content, Text, :lazy => false
  property :comment_author_url, String
  property :user_ip, String
  property :user_agent, Text, :lazy => false
  property :referrer, Text, :lazy => false
  property :is_spam, Boolean

  validates_presence_of :comment_author, :comment_author_email, :comment_content, :comment_author_url
  validates_format_of :comment_author_email, :as => :email_address

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

  def to_simple_comment
    {
      :comment_author_url => comment_author_url,
      :comment_author => comment_author,
      :readable_date => readable_date,
      :comment_content => comment_content,
      :avatar => avatar
    }
  end
  
  def to_wordpress_comment
    {
      :date_created_gmt => created_at,
      :user_id => comment_author_email,
      :comment_id => id,
      :parent => 0,
      :status => is_spam? ? "spam" : "approve",
      :content => comment_content,
      :link => post.permalink,
      :post_id => post.id,
      :post_title => post.title,
      :author => comment_author,
      :author_url => comment_author_url,
      :author_email => comment_author_email,
      :author_ip => user_ip
    }
  end

  def avatar
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(comment_author_email.downcase)}"
  end

  before :save do
    #Only check for spam if the configuration variable is set...
    #good for testing
    Blog.check_spam ? self.is_spam = spam? : self.is_spam = false
  end

  def readable_date
    created_at.to_date.strftime("%A, #{created_at.day.ordinalize} %B, %Y")
  end

  #Scope
  def self.all_active_and_ham
    all_active.all(:is_spam => false)
  end
  
  def self.all_active_and_spam
    all_active.all(:is_spam => true)
  end
end
