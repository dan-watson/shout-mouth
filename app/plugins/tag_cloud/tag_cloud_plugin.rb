class TagCloudPlugin < Plugin
  
  def data
      Tag.usable_active_tags
  end
  
end