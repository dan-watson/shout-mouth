require 'yaml'

class Blog
  
  def self.url
    configuration['url']
  end
  
  def self.akismet_key
    configuration['akismet_key']
  end
  
  def self.theme
    configuration['theme']
  end
  private 
  def self.configuration
      YAML.load_file(File.join(Dir.pwd, 'config', 'config.yaml'))["#{settings.environment.to_s}"]
  end
  
end
