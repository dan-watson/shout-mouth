class String
  def to_valid_xmlrpc_request
    self.gsub(">true<", ">1<").gsub(">false<", ">0<")
  end

  def to_boolean
    return true if self.downcase == "true"
    return false
  end
end
