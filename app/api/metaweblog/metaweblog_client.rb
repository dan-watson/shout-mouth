require 'xmlrpc/client'

class MetaweblogClient
  def initialize(server, blogid, username, password)
    @client = XMLRPC::Client.new2(server)
    @blogid = blogid
    @username = username
    @password = password
  end
  def getRecentPosts(limit)
    @client.call('metaWeblog.getRecentPosts', "1", @username,
    @password, limit)
  end
end
