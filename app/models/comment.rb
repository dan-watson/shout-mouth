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
    is_spam.nil? ? Akismetor.spam?(comment_attributes) : is_spam #means it been set by the user or already set from askimet
  end

  def avatar
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(comment_author_email.downcase)}"
  end
  
  def self.load_comments_from_xmlrpc_payload xmlrpc_call
    data = xmlrpc_call[1][3]
    
    post_id = data["post_id"]
    limit = data["number"]
    
    comments = Comment.all
    comments = comments.all(:is_spam => false)
    comments = comments.all(:is_active => true) if data["status"] == "active"
    comments = comments.all(:is_spam => true) if data["status"] == "spam"
    comments = comments.all(:is_active => false, :is_spam => false) if data["status"] == "hold" 
    comments = comments.all(:post => {:id => post_id}) unless post_id.nil?
    comments = comments.all(:limit => limit) unless limit.nil?
    
    comments
  end
  
  def self.edit_comment_from_xmlrpc_payload xmlrpc_call
    comment = Comment.get(xmlrpc_call[1][3])
    data = xmlrpc_call[1][4]
    
    comment.comment_content = data["content"]
    comment.comment_author = data["author"]
    comment.comment_author_url = data["author_url"]
    comment.comment_author_email = data["author_email"]
    
    case 
      when data["status"] == "approve"
        comment.is_active = true
        comment.is_spam = false
      when data["status"] == "spam"
        comment.is_spam = true
        comment.is_active = false
      else
        comment.is_active = false
    end
    comment
  end
  
  def self.mark_comment_as_inactive comment_id
    comment = Comment.get(comment_id)
    comment.is_active = false
    comment.save  
  end
  
  before :save do
    self.is_spam = spam?
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
