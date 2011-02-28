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
  
  def self.to_metaweblog
    [:url => self.url,
     :blogid => 2000,
     :blogName => self.site_name]
  end
  
  private 
  def self.configuration
    configuration_directory = "#{Dir.pwd}/config/"
    configuration_file = File.exist?("#{configuration_directory}_config.yaml") ? "#{configuration_directory}_config.yaml" : "#{configuration_directory}config.yaml"
    YAML.load_file(configuration_file)["#{settings.environment.to_s}"]
  end
  
end
