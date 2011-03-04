require Dir.pwd + '/app/models/base/shout_record'
require Dir.pwd + '/app/models/user'
require Dir.pwd + '/app/models/post'
require Dir.pwd + '/app/models/comment'
require Dir.pwd + '/app/models/legacy_route'
require Dir.pwd + '/app/models/blog'
require Dir.pwd + '/app/models/tag'
require Dir.pwd + '/app/models/category'
require Dir.pwd + '/app/lib/fixnum'

class Plugin  
  def data
    nil
  end
  
  def view_name
    "#{plugin_name}_plugin"
  end
  
  def view_directory
    settings.root + "/plugins/#{plugin_name}/view/"
  end
  
  def plugin_name
    self.class.name.gsub('Plugin', '').scan(/[A-Z][^A-Z]*/).join("_").downcase
  end

end
