xml.instruct!

xml.rsd "version" => "1.0" do
 xml.service do

   xml.engineName  "Shout Mouth"
   xml.engineLink  "https://github.com/dotnetguyuk/Shout-Mouth"
   xml.homePageLink Blog.url
   xml.apis do |api| 
    xml.api "name" => "WordPress", "blogID" => "1", "preferred" => "true", "apiLink" => "#{Blog.url}/xmlrpc.php"
		xml.api "name" => "Movable Type", "blogID" => "1", "preferred" => "false", "apiLink" => "#{Blog.url}/xmlrpc.php"
		xml.api "name" => "MetaWeblog", "blogID" => "1", "preferred" => "false", "apiLink" => "#{Blog.url}/xmlrpc.php"
		xml.api "name" => "Blogger", "blogID" => "1", "preferred" => "false", "apiLink" => "#{Blog.url}/xmlrpc.php"
   end
 end
end