class Upload
  def self.save_file(name, bits)
    file = "#{Dir.pwd}/public/uploads/#{name}"
    directory = File.dirname(file)

    FileUtils.makedirs(directory) unless File.directory?(directory)

    if(File.file?(file))
      File.delete(file)
    end

    File.open(file, "wb") { |f| f.write(bits) }
    File.chmod(0777, file)

    {:file => name, :url => "#{Blog.url}/uploads/#{name}"}
  end
  
end
