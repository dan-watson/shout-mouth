class CommentsPresenter
  
  def initialize(comments)
    @comments = comments
  end


  def to_wordpress_comment_count
    {
      :approved => @comments.nil? ? "0" : @comments.all_active_and_ham.count.to_s,
      :awaiting_moderation => 0, #comments are auto-moderated with askimet
      :spam => @comments.nil? ? "0" : @comments.all_active_and_spam.count.to_s,
      :total_comments => @comments.nil? ? 0 : @comments.all_active.count
    }
  end

end
