class BlogMapper
  
  def initialize(xmlrpc_call)
    @xmlrpc_call = xmlrpc_call
  end

  def update_settings
    data = @xmlrpc_call[1][3]
    output = []
    data.each do |setting|
      begin
        Blog.send("#{setting[0]}=", setting[1])
         output << setting[0].to_sym
      rescue => e
      end
    end
    output
  end

end
