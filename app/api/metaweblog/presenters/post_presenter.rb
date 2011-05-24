class PostPresenter
  
  def initialize(post)
    @post = post
  end
  
  
  def to_metaweblog
    {
      :dateCreated => @post.created_at,
      :userid => @post.user.id.to_s,
      :postid => @post.id.to_s,
      :description => @post.body,
      :title => @post.title,
      :link => @post.permalink,
      :permaLink => @post.permalink,
      :categories => @post.categories.map{|category| category.category},
      :mt_excerpt => "",
      :mt_text_more => "",
      :mt_allow_comments => 1,
      :mt_allow_pings => 0,
      :mt_keywords => @post.readable_tags.gsub(" ", ""),
      :wp_slug => @post.slug,
      :wp_password => "",
      :wp_author_id => @post.user.id.to_s,
      :wp_author_display_name => @post.user.fullname,
      :date_created_gmt => @post.created_at,
      :post_status => PostStatus.status_from_boolean(@post.is_active),
      :custom_fields => [
                          {
                            :id => "2",
                            :key => "_edit_last",
                            :value => @post.user.id.to_s
        
                          },
                          {
                            :id => "1",
                            :key => "_edit_lock",
                            :value => "#1299280582:#{@post.user.id.to_s}"
                          }
                        ],
      :wp_post_format => "standard"
      #:publish => is_active
    }
  end
  
  def to_blogger
    {
      :userid => @post.user.id.to_s,
      :dateCreated => @post.created_at,
      :content => "<title>#{@post.title}</title><category>#{@post.categories.map{|category| category.id.to_s}.join(",")}</category>#{@post.body}",
      :postid => @post.id.to_s
    }
  end
  
  def to_movable_type
    {
      :dateCreated => @post.created_at,
      :userid => @post.user.id.to_s,
      :postid => @post.id.to_s,
      :title => @post.title,
      :date_created_gmt => @post.created_at
    }
  end
  
  def to_minimal_wordpress_page
    {
      :page_id => @post.id.to_s,
      :page_title => @post.title,
      :page_parent_id => @post.parent_page_id.to_s,
      :dateCreated => @post.created_at,
      :date_created_gmt => @post.created_at
    }
  end
  
  def to_wordpress_page
    {
      :dateCreated => @post.created_at,
      :userid => @post.user.id.to_s,
      :page_id => @post.id,
      :page_status =>  PostStatus.status_from_boolean(@post.is_active),
      :description => @post.body,
      :title => @post.title,
      :link => @post.permalink,
      :permaLink => @post.permalink,
      :categories => [],#categories.map{|category| category.category},
      :excerpt => "",
      :text_more => "",
      :mt_allow_comments => 0,
      :mt_allow_pings => 0,
      :wp_slug => @post.slug,
      :wp_password => "",
      :wp_author => @post.user.email,
      :wp_page_parent_id => @post.parent_page_id,
      :wp_page_parent_title => "",
      :wp_page_order => @post.page_order,
      :wp_author_id => @post.user.id.to_s,
      :wp_author_display_name => @post.user.fullname, #possible need to be email,
      :date_created_gmt => @post.created_at,
      #:mt_convert_breaks => "__default__",
      #:page_parent_id => "0",
      :custom_fields => [
        {
          :id => "13",
          :key => "localDraftUniqueID",
          :value => @post.local_draft_id
        }
      ],
      :wp_page_template => "default"
        
    }
  end
  
  def to_wordpress_comment_count
    {
      :approved => @post.comments.nil? ? "0" : @post.comments.all_active_and_ham.count.to_s,
      :awaiting_moderation => 0, #comments are auto-moderated with askimet
      :spam => @post.comments.nil? ? "0" : @post.comments.all_active_and_spam.count.to_s,
      :total_comments => @post.comments.nil? ? 0 : @post.comments.all_active.count
    }
  end
  
end
