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
      :software_name => {:desc => "Software Name", :readonly => true, :value => "ShoutMouth"},
      :software_version => {:desc => "Software Version", :readonly => true, :value => "MU"},
      :blog_url => {:desc => "Site URL", :readonly => true, :value => @blog.url},
      :time_zone => {:desc => "Time Zone", :readonly => true, :value => "0"}, #wordpress readonly is false
      :blog_title => {:desc => "Site Title", :readonly => true, :value => @blog.site_name}, #wordpress readonly is false
      :blog_tagline => {:desc => "Site Tagline", :readonly => true, :value => @blog.site_description}, #wordpress readonly is false
      :date_format => {:desc => "Date Format", :readonly => true, :value => "F j, Y"}, #wordpress readonly is false - wtf? F j y????
      :time_format => {:desc => "Time Format", :readonly => true, :value => "g:i a"}, #wordpress readonly is false - wtf? g:i a????
      :users_can_register => {:desc => "Allow new users to sign up", :readonly => true, :value => false}, #wordpress readonly is false
      :thumbnail_size_w => {:desc => "Thumbnail Width", :readonly => true, :value => 150}, #wordpress readonly is false
      :thumbnail_size_h => {:desc => "Thumbnail Height", :readonly => true, :value => 150}, #wordpress readonly is false
      :thumbnail_crop => {:desc => "Crop thumbnail to exact dimensions", :readonly => true, :value => 0}, #wordpress readonly is false
      :medium_size_w => {:desc => "Medium size image width", :readonly => true, :value => "300"}, #wordpress readonly is false
      :medium_size_h => {:desc => "Medium size image height", :readonly => true, :value => "300"}, #wordpress readonly is false
      :large_size_w => {:desc => "Large size image width", :readonly => true, :value => "1024"}, #wordpress readonly is false
      :large_size_h => {:desc => "Large size image height", :readonly => true, :value => "1024"} #wordpress readonly is false
    }
  end
  
end