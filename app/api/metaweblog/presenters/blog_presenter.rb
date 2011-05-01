class BlogPresenter
  
  def initialize(blog)
    @blog = blog
  end
  
  def to_metaweblog
    [
      :isAdmin => true,
      :url => @blog.url,
      :blogid => 2000,
      :blogName => @blog.site_name,
      :xmlrpc => "#{@blog.url}/xmlrpc.php"
    ]
  end
  
  def to_wordpress_options
    {
      :software_name => {:desc => "Software Name", :readonly => true, :value => "Shout Mouth Blog Engine"},
      :url => {:desc => "Site URL", :readonly => false, :value => @blog.url},
      :site_name => {:desc => "Site Title", :readonly => false, :value => @blog.site_name},
      :site_description => {:desc => "Site Tagline", :readonly => false, :value => @blog.site_description},
      :posts_on_home_page => {:desc => "Posts to display on home page", :readonly => false, :value => @blog.posts_on_home_page},
      :aksimet_key => {:desc => "Akismet Key", :readonly => false, :value => @blog.akismet_key},
      :amazon_s3_key => {:desc => "Amazon S3 Key", :readonly => false, :value => @blog.amazon_s3_key},
      :amazon_secret_key => {:desc => "Amazon Secret Key", :readonly => false, :value => @blog.amazon_s3_secret_key},
      :amazon_s3_bucket => {:desc => "Amazon S3 Bucket", :readonly => false, :value => @blog.amazon_s3_bucket},
      :amazon_s3_file_location => {:desc => "Amazon S3 URL", :readonly => false, :value => @blog.amazon_s3_file_location},
      :theme => {:desc => "Site Theme", :readonly => false, :value => @blog.theme},
      :twitter_account => {:desc => "Twitter Account", :readonly => false, :value => @blog.twitter_account},
      :check_spam => {:desc => "Check for spam?", :readonly => false, :value => @blog.check_spam},
      :comments_open_for_days => {:desc => "How many days should comments be open for?", :readonly => false, :value => @blog.comments_open_for_days},
      :use_file_based_storage => {:desc => "Use filesystem to store assets instead of Amazon S3?", :readonly => false, :value => @blog.use_file_based_storage},
      :footer_more_text => {:desc => "Text to display in the footer", :readonly => false, :value => @blog.footer_more_text},
      :google_analytics_key => {:desc => "Google Analytics Key", :readonly => false, :value => @blog.google_analytics_key},
      :use_google_analytics => {:desc => "Use Google analytics?", :readonly => false, :value => @blog.use_google_analytics},
      :smtp_settings => {:desc => "SMTP Settings", :readonly => false, :value => @blog.smtp_settings},
      :site_email => {:desc => "Email address the site send's mail from", :readonly => false, :value => @blog.site_email},
      :administrator_email => {:desc => "Email address of the author / site administrator", :readonly => false, :value => @blog.administrator_email}
    }
  end
  
  def to_wordpress_options_subset options
    to_wordpress_options.reject { |key,_| !options.include? key }
  end
end
