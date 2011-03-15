xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
 xml.channel do

   xml.title       Blog.site_name
   xml.link        Blog.url
   xml.description Blog.site_description

   @posts.each do |post|
     xml.item do
       xml.title       post.title
       xml.link        post.permalink
       xml.description post.body
       xml.guid        post.permalink
       xml.pubDate     post.created_at.to_s
       xml.category :term => post.readable_tags
     end
   end

 end
end