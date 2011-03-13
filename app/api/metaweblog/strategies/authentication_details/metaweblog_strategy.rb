class MetaweblogStrategy < DefaultStrategy
  
  def authentication_details_from(method, xmlrpc_call)
    case method
      when "set_template", "get_template"
        {:username => xmlrpc_call[1][2], :password => xmlrpc_call[1][3]} 
      else
        #Better to be explicit here
        super(method,xmlrpc_call)
    end
  end
  
end