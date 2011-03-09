class String
  def to_valid_xmlrpc_request
    self.gsub("true", "1").gsub("false", "0")
  end
end