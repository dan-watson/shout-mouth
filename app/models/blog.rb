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

  def self.check_spam
    configuration['check_spam']
  end

  def self.comments_open_for_days
    configuration['comments_open_for_days'].to_i
  end
  
  def self.use_file_based_storage
    configuration['use_file_based_storage']
  end
  
  def self.footer_more_text
    configuration['footer_more_text']
  end
  
  def self.google_analytics_key
    configuration['google_analytics_key']
  end
  
  def self.use_google_analytics
    self.google_analytics_key.length > 0
  end
  
  def self.smtp_settings
    {
        :host     =>  configuration['smtp_host'],     #'smtp.yourserver.com',
        :port     =>  configuration['smtp_port'],     #'25',
        :user     =>  configuration['smtp_user'],     #'user',
        :password =>  configuration['smtp_password'], #'pass',
        :auth     => :plain,                          #:login, :cram_md5, no auth by default
        :domain   =>  configuration['smtp_domain']    #example.com - the HELO domain provided by the client to the server
      }
  end
  
  def self.site_email
    configuration['site_email']
  end
  
  def self.administrator_email
    configuration['administrator_email']
  end
  
  private
  def self.configuration
    configuration_directory = "#{Dir.pwd}/config/"
    configuration_file = File.exist?("#{configuration_directory}_config.yaml") ? "#{configuration_directory}_config.yaml" : "#{configuration_directory}config.yaml"
    YAML.load_file(configuration_file)["#{settings.environment.to_s}"]
  end

end
