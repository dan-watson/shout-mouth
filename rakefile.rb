namespace :db do
  require 'fileutils'
  require 'dm-core'
  require 'dm-migrations'
  require File.dirname(__FILE__) + '/app/shout_mouth.rb'

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
  desc "Import Blog - import url=http://yourblog.com user=username password=password posts=number_of_posts current_user_email=email from_blog_engine={{your_engine}}"
  task :posts do |t, args|
    Comment.destroy
    Post.destroy
    LegacyRoute.destroy

    user = User.find(:email => args.current_user).first
    client = MetaweblogClient.new(args.url, "1000", args.user, args.password)

    if(user)
      puts "user found"

      posts = client.getRecentPosts(args.posts)

      posts.each{|post|
        new_post = Post.new(:title => post['title'],
        :body => post['description'],
        :tags => post['mt_keywords'],
        :categories => post['categories'].join(", "),
        :created_at => post['dateCreated'].to_date,
        :user => user)

        if(args.from_blog_engine == "blogengine.net")
          new_post.add_legacy_route "post.aspx?id=#{post['postid']}"
          new_post.add_legacy_route URI.parse(post['link']).path.split("/").last
        end
        
        new_post.save
      }

    end

  end
end

namespace :users do
  desc "Create a use - create email=email password=password firstname=firstname lastname=lastname"
  task :create do |t, args|
    User.new(:email => args.email, :password => args.password, :firstname => args.firstname, :lastname => args.lastname).save
  end
end
