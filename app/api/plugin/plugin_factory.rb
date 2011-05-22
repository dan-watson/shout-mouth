require Dir.pwd + '/app/api/plugin/plugin'
require 'singleton'

class PluginFactory
 include ::Singleton
  
  def get_plugin(symbol)
      Object::const_get("#{symbol.to_s.split("_").each{|s| s.capitalize!}.join}Plugin").new
  end
    
  private 
  def initialize
    load_plugins
  end
  
  def get_plugin_directory
    settings.root + "/plugins"
  end
  
  def get_plugin_directories
      Dir["#{get_plugin_directory}/*/"]
  end
  
  def load_plugins
      get_plugin_directories.each{|directory|
        file = directory.split("/").last + "_plugin.rb"
        require directory + file
      }
  end
end
