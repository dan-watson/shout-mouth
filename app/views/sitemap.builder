xml.instruct!

xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
   @articles.each do |article|
     xml.url do
       xml.loc         article.permalink
       xml.lastmod     article.created_at.strftime("%Y-%m-%d")
       xml.changefreq  "monthly"
     end
   end
 end

