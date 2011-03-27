xml.instruct!

xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
	
	xml.url do 
		xml.loc 		Blog.url
		xml.lastmod 	DateTime.now.strftime("%Y-%m-%d")
		xml.changefreq  "weekly"
	end
	
   @articles.each do |article|
     xml.url do
       xml.loc         article.permalink
       xml.lastmod     article.created_at.strftime("%Y-%m-%d")
       xml.changefreq  "monthly"
     end
   end
 end

