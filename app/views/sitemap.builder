xml.instruct!

xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
	
	xml.url do 
		xml.loc 		Blog.url
		xml.lastmod 	DateTime.now.strftime("%Y-%m-%d")
		xml.changefreq  "weekly"
	end
	
	xml.url do 
		xml.loc 		"#{Blog.url}/archive"
		xml.lastmod 	DateTime.now.strftime("%Y-%m-%d")
		xml.changefreq  "weekly"
	end

   @pages.each do |page|
     xml.url do
       xml.loc         page[:page]
       xml.lastmod     page[:created_at].strftime("%Y-%m-%d")
       xml.changefreq  "monthly"
     end
   end
 end

