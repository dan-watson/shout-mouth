require 'yaml'

class Blog

  def self.posts_on_home_page
    configuration['posts_on_home_page']
  end

  def self.url
    configuration['url']
  end

  def self.akismet_key
    configuration['akismet_key']
  end

  def self.amazon_s3_key
    configuration['amazon_s3_key']
  end

  def self.amazon_s3_secret_key
    configuration['amazon_s3_secret_key']
  end

  def self.amazon_s3_bucket
    configuration['amazon_s3_bucket']
  end

  def self.amazon_s3_file_location
    configuration['amazon_s3_file_location']
  end

  def self.theme
    configuration['theme']
  end

  def self.site_name
    configuration['site_name']
  end

  def self.site_description
    configuration['site_description']
  end

  def self.twitter_account
    configuration['twitter_account']
  end

  def self.to_metaweblog
    [
      :isAdmin => true,
      :url => self.url,
      :blogid => 2000,
      :blogName => self.site_name,
      :xmlrpc => "#{self.url}/xmlrpc.php"
    ]
  end
  
  def self.to_wordpress_options
    {
      :software_name => {:desc => "Software Name", :readonly => true, :value => "ShoutMouth"},
      :software_version => {:desc => "Software Version", :readonly => true, :value => "MU"},
      :blog_url => {:desc => "Site URL", :readonly => true, :value => self.url},
      :time_zone => {:desc => "Time Zone", :readonly => true, :value => "0"}, #wordpress readonly is false
      :blog_title => {:desc => "Site Title", :readonly => true, :value => self.site_name}, #wordpress readonly is false
      :blog_tagline => {:desc => "Site Tagline", :readonly => true, :value => self.site_description}, #wordpress readonly is false
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

  def self.check_spam
    configuration['check_spam']
  end

  def self.comments_open_for_days
    configuration['comments_open_for_days'].to_i
  end

  private
  def self.configuration
    configuration_directory = "#{Dir.pwd}/config/"
    configuration_file = File.exist?("#{configuration_directory}_config.yaml") ? "#{configuration_directory}_config.yaml" : "#{configuration_directory}config.yaml"
    YAML.load_file(configuration_file)["#{settings.environment.to_s}"]
  end

end
