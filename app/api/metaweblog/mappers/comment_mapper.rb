class CommentMapper
  
  def initialize(xmlrpc_call)
    @xmlrpc_call = xmlrpc_call
  end
  
  def load_comments_from_xmlrpc_payload
    data = @xmlrpc_call[1][3]
    
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
  
  
  def edit_comment_from_xmlrpc_payload
    comment = Comment.get(@xmlrpc_call[1][3])
    data = @xmlrpc_call[1][4]
    
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
  
end