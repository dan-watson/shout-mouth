class CommentPresenter
  
  def initialize(comment)
    @comment = comment
  end
    
  def to_wordpress_comment
    {
      :date_created_gmt =>  @comment.created_at,
      :user_id =>  @comment.comment_author_email,
      :comment_id =>  @comment.id.to_s,
      :parent => "0",
      :status =>  @comment.is_spam? ? "spam" :  @comment.is_active ? "approve" : "hold",
      :content =>  @comment.comment_content,
      :link =>  @comment.post.permalink,
      :post_id =>  @comment.post.id.to_s,
      :post_title =>  @comment.post.title,
      :author =>  @comment.comment_author,
      :author_url =>  @comment.comment_author_url,
      :author_email =>  @comment.comment_author_email,
      :author_ip =>  @comment.user_ip,
      :type => ""
    }
  end
  
  def self.comment_status_list
    {
      :hold => "Unapproved",
      :approve => "Approved",
      :spam => "Spam"
    }
  end
  
  
end