class UserPresenter
  def initialize(user)
    @user = user
  end
  
  def to_metaweblog
    {
      :nickname => @user.fullname,
      :userid => @user.id.to_s,
      :url => Blog.url,
      :lastname => @user.lastname,
      :firstname => @user.firstname
      #:email => email
    }
  end
  
  def to_wordpress_author
    {
      :user_id => @user.id.to_s,
      :user_login => @user.email,
      :display_name => @user.fullname,
      :user_email => @user.email
      #:meta_value => ""
    }
  end
  
end