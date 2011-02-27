xml.instruct!

xml.rsd "version" => "1.0" do
 xml.service do

   xml.engineName  "Shout Mouth"
   xml.engineLink  "https://github.com/dotnetguyuk/Shout-Mouth"
   xml.homePageLink Blog.url
   xml.apis do |api| 
		xml.api "name" => "MetaWeblog", "preferred" => "true", "apiLink" => "#{Blog.url}/xmlrpc/", "blogID" => 2000
   end
 end
end