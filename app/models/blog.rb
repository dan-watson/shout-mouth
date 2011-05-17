require 'yaml'
require 'rake'

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
    create_or_update 'posts_on_home_page', value.to_i
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
    create_or_update 'check_spam', value.to_s.to_boolean
  end
  #----------------------------#
  def self.comments_open_for_days
    configuration 'comments_open_for_days'
  end
  
  def self.comments_open_for_days=(value)
    create_or_update 'comments_open_for_days', value.to_i
    CacheCleaner.clear_cache
  end
  #----------------------------#  
  def self.use_file_based_storage
    configuration 'use_file_based_storage'
  end
  
  def self.use_file_based_storage=(value)
    create_or_update 'use_file_based_storage', value.to_s.to_boolean
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
    !self.google_analytics_key.nil? && self.google_analytics_key.length > 0
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
  
  def self.setup(settings)
   #Create the database
   system "rake -f rakefile.rb db:create" 
   #Settings needed to valid blog setup
   settings_needed = ["url", "site_name", "site_description", "posts_on_home_page", "footer_more_text", "check_spam", "akismet_key", "comments_open_for_days_check", 
                      "comments_open_for_days", "use_file_based_storage","amazon_s3_key", "amazon_s3_secret_key", "amazon_s3_bucket", "amazon_s3_file_location",
                      "theme", "twitter_account", "use_google_analytics", "google_analytics_key", "smtp_host", "smtp_port", "smtp_user", "smtp_password", "smtp_auth", 
                      "smtp_domain", "site_email", "administrator_email", "categories", "user"]
   
   #Validate all the settings needed for setup exist
   return false unless settings.has_keys?(settings_needed)

   #Validate each setting has a valid value - could be split out into a seperate validation class to seperate concerns but going to inline it even
   #though the method is large it is more obvious what it going on.

   errors = []
   errors << "Valid site url is required" unless settings["url"].length > 0 && settings["url"] =~ Regexp.new(Regexp::URL)
   errors << "Site name is required" unless settings["site_name"].length > 0
   errors << "Site description is required" unless settings["site_description"].length > 0
   errors << "Posts on home page must be numeric" unless settings["posts_on_home_page"] !~ Regexp.new(Regexp::NUMERIC)
   errors << "Check spam must be true or false" unless settings["check_spam"] == "true" || settings["check_spam"] == "false"
   errors << "Akismet key is required" if settings["check_spam"] == "true" && settings["akismet_key"].length == 0 
   errors << "Comments open for days must be numeric" unless settings["comments_open_for_days"] !~ Regexp.new(Regexp::NUMERIC)
   errors << "Amazon S3 key is required" if settings["use_file_based_storage"] == "false" && settings["amazon_s3_key"].length == 0
   errors << "Amazon S3 secret key is required" if settings["use_file_based_storage"] == "false" && settings["amazon_s3_secret_key"].length == 0
   errors << "Amazon S3 bucket is required" if settings["use_file_based_storage"] == "false" && settings["amazon_s3_bucket"].length == 0
   errors << "Amazon S3 file location is required" if settings["use_file_based_storage"] == "false" && settings["amazon_s3_file_location"].length == 0
   errors << "Theme is required" unless settings["theme"].length > 0
   errors << "Twitter account is required" unless settings["twitter_account"].length > 0
   errors << "Google analytics key is required" if settings["use_google_analytics"] == "true" && settings["google_analytics_key"].length == 0
   errors << "SMTP host is required" unless settings["smtp_host"].length > 0
   errors << "SMTP port is required" unless settings["smtp_port"].length > 0
   errors << "SMTP user is required" unless settings["smtp_user"].length > 0
   errors << "SMTP password is required" unless settings["smtp_password"].length > 0
   errors << "SMTP authentication type is required" unless settings["smtp_auth"].length > 0
   errors << "SMTP domain type is required" unless settings["smtp_domain"].length > 0
   errors << "Categories are required" unless settings["categories"].length > 0
   errors << "Valid site email is required" unless settings["site_email"].length > 0 && settings["site_email"] =~ Regexp.new(Regexp::EMAIL)
   errors << "Valid administrator email is required" unless settings["administrator_email"].length > 0 && settings["administrator_email"] =~ Regexp.new(Regexp::EMAIL)
   errors << "User first name is required" unless settings["user"]["firstname"].length > 0
   errors << "User last name is required" unless settings["user"]["lastname"].length > 0
   errors << "User email address is required" unless settings["user"]["email"].length > 0 && settings["user"]["email"] =~ Regexp.new(Regexp::EMAIL)
   errors << "Password and password confirmation are required" unless settings["user"]["password"].length > 0 || settings["user"]["password_confirm"].length > 0
   errors << "Password and password confirmation must match" unless settings["user"]["password"] == settings["user"]["password_confirm"]
   return errors if errors.any?
    
   #Time to update the settings

   settings.each{|setting|
     begin 
      Blog.send("#{setting[0]}=", setting[1])
     rescue NoMethodError
      #Not all the passed in params are methods on the blog class
     end
   }
   
   
   Category.categories_from_array(settings["categories"].split(",").each{|i| i.strip!})

   User.new(:email => settings["user"]["email"], 
            :password => settings["user"]["password"], 
            :firstname => settings["user"]["firstname"],
            :lastname => settings["user"]["lastname"]).save

   return true
  end  

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
