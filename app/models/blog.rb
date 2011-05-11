require 'yaml'

class Blog
    include Shout::Record
        
    storage_names[:default] = "settings"

    property :key_name, String, :length => 200
    property :value, String, :length => 200
    property :type, String, :length => 50
    
    validates_presence_of :key_name, :value, :type
    
  def self.posts_on_home_page
    configuration 'posts_on_home_page'
  end
  
  def self.posts_on_home_page=(value)
    create_or_update 'posts_on_home_page', value
    CacheCleaner.clear_cache_for 'index'
  end
  #----------------------------#
  def self.url
    configuration 'url'
  end
  
  def self.url=(value)
    create_or_update 'url', value
    CacheCleaner.clear_cache
  end
  #----------------------------#
  def self.akismet_key
    configuration 'akismet_key'
  end
  
  def self.akismet_key=(value)
    create_or_update 'akismet_key', value
  end
  #----------------------------#
  def self.amazon_s3_key
    configuration 'amazon_s3_key'
  end
  
  def self.amazon_s3_key=(value)
    create_or_update 'amazon_s3_key', value
  end
  #----------------------------#
  def self.amazon_s3_secret_key
    configuration 'amazon_s3_secret_key'
  end
  
  def self.amazon_s3_secret_key=(value)
    create_or_update 'amazon_s3_secret_key', value
  end
  #----------------------------#
  def self.amazon_s3_bucket
    configuration 'amazon_s3_bucket'
  end
  
  def self.amazon_s3_bucket=(value)
    create_or_update 'amazon_s3_bucket', value
  end
  #----------------------------#
  def self.amazon_s3_file_location
    configuration 'amazon_s3_file_location'
  end
  
  def self.amazon_s3_file_location=(value)
    create_or_update 'amazon_s3_file_location', value
  end
  #----------------------------#
  def self.theme
    configuration 'theme'
  end
  
  def self.theme=(value)
    create_or_update 'theme', value
    CacheCleaner.clear_cache
  end
  #----------------------------#
  def self.site_name
    configuration 'site_name'
  end
  
  def self.site_name=(value)
    create_or_update 'site_name', value
    CacheCleaner.clear_cache
  end
  #----------------------------#
  def self.site_description
    configuration 'site_description'
  end
  
  def self.site_description=(value)
    create_or_update 'site_description', value
    CacheCleaner.clear_cache
  end
  #----------------------------#
  def self.twitter_account
    configuration 'twitter_account'
  end
  
  def self.twitter_account=(value)
    create_or_update 'twitter_account', value
    CacheCleaner.clear_cache
  end
  #----------------------------#
  def self.check_spam
    configuration 'check_spam'
  end
  
  def self.check_spam=(value)
    create_or_update 'check_spam', value
  end
  #----------------------------#
  def self.comments_open_for_days
    configuration 'comments_open_for_days'
  end
  
  def self.comments_open_for_days=(value)
    create_or_update 'comments_open_for_days', value
    CacheCleaner.clear_cache
  end
  #----------------------------#  
  def self.use_file_based_storage
    configuration 'use_file_based_storage'
  end
  
  def self.use_file_based_storage=(value)
    create_or_update 'use_file_based_storage', value
  end
  #----------------------------#  
  def self.footer_more_text
    configuration 'footer_more_text'
  end
  
  def self.footer_more_text=(value)
    create_or_update 'footer_more_text', value
    CacheCleaner.clear_cache
  end
  #----------------------------#
  def self.google_analytics_key
    configuration 'google_analytics_key'
  end
  
  def self.google_analytics_key=(value)
    create_or_update 'google_analytics_key', value
    CacheCleaner.clear_cache
  end
  #----------------------------#
  def self.use_google_analytics
    self.google_analytics_key.length > 0
  end
  #----------------------------#  
  def self.smtp_settings
    {
        :host     =>  configuration('smtp_host'),     #'smtp.yourserver.com',
        :port     =>  configuration('smtp_port'),     #'25',
        :user     =>  configuration('smtp_user'),     #'user',
        :password =>  configuration('smtp_password'), #'pass',
        :auth     =>  configuration('smtp_auth').nil? ? :plain : configuration('smtp_auth').to_sym,  #:login, :cram_md5, no auth by default
        :domain   =>  configuration('smtp_domain')    #example.com - the HELO domain provided by the client to the server
      }
  end
  
  def self.smtp_host=(value)
    create_or_update 'smtp_host', value
  end
  
  def self.smtp_port=(value)
    create_or_update 'smtp_port', value
  end
  
  def self.smtp_user=(value)
    create_or_update 'smtp_user', value
  end
  
  def self.smtp_password=(value)
    create_or_update 'smtp_password', value
  end
 
  def self.smtp_auth=(value)
    create_or_update 'smtp_auth', value
  end

  def self.smtp_domain=(value)
    create_or_update 'smtp_domain', value
  end
  #----------------------------#
  def self.site_email
    configuration 'site_email'
  end
  
  def self.site_email=(value)
    create_or_update 'site_email', value
  end
  #----------------------------#
  def self.administrator_email
    configuration 'administrator_email'
  end
  
  def self.administrator_email=(value)
    create_or_update 'administrator_email', value
  end
  #----------------------------#
    
  private
  def self.configuration setting
    entry = Blog.first(:key_name => setting) 
    entry.nil? ? nil : entry.value.cast_to(entry.type)
  end
  
  def self.create_or_update setting, value
     attributes = {:value => value, :type => value.class}
     blog_setting = Blog.first_or_create({:key_name => setting}, {:key_name => setting}.merge(attributes))
     blog_setting.update(attributes) unless blog_setting.new?
     blog_setting.save
  end
end
