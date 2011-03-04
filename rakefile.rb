namespace :db do
  require 'fileutils'
  require 'dm-core'
  require 'dm-migrations'
  require File.dirname(__FILE__) + '/app/shout_mouth.rb'
  require File.dirname(__FILE__) + '/tests/test_data/test_data_helper'
  desc "Create The Database"
  task :create do |t, args|
    DataMapper.auto_migrate!
  end

  desc "Upgrade The Database"
  task :update do |t, args|
    DataMapper.auto_upgrade!
  end

  desc "Delete Database File"
  task :delete do |t, args|
    FileUtils.rm_rf(File.dirname(__FILE__) + "/db/shout_mouth.db")
  end
  
  desc "Seed Demo Data"
  task :demo_data do |t, args|
      Rake::Task["db:create"].invoke
      TestDataHelper.wipe_database
      TestDataHelper.valid_post
      TestDataHelper.valid_post1
      TestDataHelper.valid_post2
      TestDataHelper.valid_comment
      TestDataHelper.legacy_route
  end
end

namespace :specs do
  ENV['RACK_ENV'] = 'test'

  desc "Run All The Specs"
  task :run_all do |t, args|
    Rake::Task["db:create"].invoke
    exec 'rspec -c ' + File.dirname(__FILE__) + '/tests/*.rb'
  end
end


namespace :import do
  require File.dirname(__FILE__) + '/app/api/metaweblog_client.rb'
  require 'uri'
  require 'nokogiri'

  desc "Import Posts - import url=http://yourblog.com user=username password=password posts=number_of_posts current_user_email=email from_blog_engine={{your_engine}}"
  task :posts do |t, args|
    Comment.destroy
    Post.destroy
    Tag.destroy
    Category.destroy
    LegacyRoute.destroy

    user = User.all(:email => args.current_user_email).first
    client = MetaweblogClient.new(args.url, "1000", args.user, args.password)

    if(user)
      puts "user found"

      posts = client.getRecentPosts(args.posts)

      posts.each{|post|
        new_post = Post.new(:title => post['title'],
        :body => post['description'],
        :tags => Tag.tags_from_array(post['mt_keywords'].split(",")),
        :categories => Category.categories_from_array(post['categories']),
        :created_at => post['dateCreated'].to_date,
        :user => user)

        case args.from_blog_engine
        when "blogengine.net"
          new_post.add_legacy_route "post.aspx?id=#{post['postid']}"
          new_post.add_legacy_route URI.parse(post['link']).path.split("/").last
        when "wordpress"
          #who ever reads this - you will need to write your own legacy route setter
          #if your current blog does not support /post/{integer}/{integer}/{interger}/slug
          #then do not just add the slug part to the legacy route - add the requests.path ie :- /posty/july/mypost
          puts "not implemented"
        end

        new_post.save
        
      }
      puts "import complete"
    end
  end

  desc "Scrape current posts looking for images and downloads which will then be uploaded to the file store -
    currently looks for images types jpg, gif, png
    currently looks for download types zip, rar
    will match filename in urls as so - http://url.com/file.png or http://url.com/image?name=file.png (will look for the last =)
    if this does not suit then you will need to write your own regex to pick filenames from urls
    EXAMPLE: rake import:repoint_images upload=1
    --if upload=0 it will repoint the urls saved in the db but not upload the images to amazon s3 - will use s3 production settings"

    task :repoint_images do |t, args|
      ENV['RACK_ENV'] = 'production'

      #Get all the images and downloads
      Post.each{|post|
        images = []
        downloads = []

        uri_collection = URI.extract post.body

        uri_collection.each{|uri|
          images << uri if uri.downcase =~ /.(?:jpg|gif|png)$/
          downloads << uri if uri.downcase =~ /.(?:zip|rar)$/
        }

        #Remove duplicates
        images.uniq!
        downloads.uniq!

        #going to upload files to s3 and replace references in the html
        body = post.body
        upload = false
        upload = true if (args.upload == "1")
        
        images.each{|old_url|
            new_url = upload_file(old_url, upload)
            body = replace_references(body, old_url, new_url)
        }
        downloads.each{|old_url| 
          new_url = upload_file(old_url, upload)
          body = replace_references(body, old_url, new_url)
        }
        #saving all the paths that were http://yourblog.com/images/pic.jpg that will now be http://s3.amazon.com/bucket/pic.jpg 
        post.body = body
        post.save

        puts "Total Link Files For #{post.title}: #{downloads.count}"
        puts "Total Image Files For #{post.title}: #{images.count}"
      }

    end

    desc "Remove image tags height and width - I have found that my current blog client adds height and width to image tags
    and I do not want them there as it is screwing my new layout - rake task removes height='?' width='?' from all posts image tags"
    task :remove_height_and_width_from_images do |t, args|
      int = 0
      Post.all.each{|post|
        
        body = post.body
        doc = Nokogiri::HTML(body)
        doc.xpath("//img").each{|image| 
          image.remove_attribute "height"
          image.remove_attribute "width"
        }
        post.body = doc.to_s
        post.save
      }
    end
    
    private 
    def upload_file(url, upload)
      uri = URI.parse(url)
      name = url.split('/').last.gsub(/(.*=)/, "").downcase 
            
      if(upload)
        Net::HTTP.start(uri.host) { |http|
          resp = http.get(uri.request_uri)
          AmazonS3.save_file(name, resp.body)
        }
      end
      puts "-----------------CHANGE: #{url} > #{Blog.amazon_s3_file_location}#{Blog.amazon_s3_bucket}/#{name}"
      return "#{Blog.amazon_s3_file_location}#{Blog.amazon_s3_bucket}/#{name}"
    end

    def replace_references(body, old_url, new_url)
      body.gsub(old_url, new_url)
    end

  end

  namespace :users do
    desc "Create a use - create email=email password=password firstname=firstname lastname=lastname"
    task :create do |t, args|
      User.new(:email => args.email, :password => args.password, :firstname => args.firstname, :lastname => args.lastname).save
    end
  end
