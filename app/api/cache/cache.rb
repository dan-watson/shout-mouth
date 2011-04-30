class Cache
  def self.clear_cache
    FileUtils.rm_rf(Dir.glob("#{cache_path}/*"))
  end
  
  def self.cache_path
    File.join(File.dirname(__FILE__) , "..", "..", "..", "public", "cache")
  end
  
  def self.clear_cache_for page, type = "html"
    FileUtils.rm_rf(File.join(cache_path, "#{page.to_s}.#{type}"))
  end
end