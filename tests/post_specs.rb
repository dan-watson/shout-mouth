require File.dirname(__FILE__) + '/../app/shout_mouth.rb'

require 'rspec'

describe Post, "validation" do
  it "should not be valid if the title and body are not present" do
    post = Post.new
    post.should_not be_valid
  end
  
  it "should be valid if the required fields are supplied correctly" do
    #arrange
    user = User.new(:email => "test@rails.com", :password => "password@1", :firstname => "Test", :lastname => "Rails")
    user.save
    post = Post.new(:title => "T1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :user => user)
    #assert
    post.should be_valid
  end
  
end

describe Post, "defaults" do
  it "should have the active flag set to true" do
    post = Post.new(:title => "T1", :body => "bd1")
    post.is_active.should be_true
  end
  
  it "should have the created_at date and time set" do
    post = Post.new(:title => "T1", :body => "bd1")
    post.created_at.should_not be_nil
  end
  
  it "should have the is_page value set to false" do
    post = Post.new(:title => "T1", :body => "bd1")
    post.is_page.should be_false
  end
  
  it "should have the month and year property set after saving" do
    #arrange
    user = User.new(:email => "test@rails.com", :password => "password@1", :firstname => "Test", :lastname => "Rails")
    user.save
    post = Post.new(:title => "T1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :user => user)
    post.save
    #assert
    post.year.should == DateTime.now.year
    post.month.should == DateTime.now.strftime("%B")
  end
end

describe Post, "slug" do
    it "should change the title to a valid url string" do
      post = Post.new(:title => "The wheels on my bus don't go round and round!", :body => "bd1")
      post.slug.should == "the-wheels-on-my-bus-dont-go-round-and-round"
    end
end

describe Post, "permalink" do
  it " should join the blog url and slug correctly" do
      post = Post.new(:title => "The wheels on my bus don't go round and round!", :body => "bd1")
      post.permalink.should == "http://192.168.1.68:9393/post/#{DateTime.now.to_date.strftime("%Y/%m/%d")}/the-wheels-on-my-bus-dont-go-round-and-round"
  end
  
  it "should persist the slug to the database" do
    #arrange
    user = User.new(:email => "test@rails.com", :password => "password@1", :firstname => "Test", :lastname => "Rails")
    user.save
    post = Post.new(:title => "T1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :user => user)
    post.save
    #assert
    post.persisted_slug.should == post.slug
  end
end

describe Post, "helper methods" do
  it "should give the correct human readable date" do
     post = Post.new(:title => "T1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :created_at => Date.new(2010,01,01))
     post.readable_date.should == "Friday, 1st January, 2010"
  end
  
  it "should give the correct author name" do
     user = User.new(:email => "test@rails.com", :password => "password@1", :firstname => "Test", :lastname => "Rails")
     user.save
     post = Post.new(:title => "T1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :user => user)
     post.author.should == "Test Rails"
  end
  
  it "should give the correct human readable tags" do
     user = User.new(:email => "test@rails.com", :password => "password@1", :firstname => "Test", :lastname => "Rails")
     user.save
     post = Post.new(:title => "T1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :user => user)
     post.save
     post.reload
     post.readable_tags.should == "tag1, tag2"
  end
  
  it "should give the correct human readable categories" do
     user = User.new(:email => "test@rails.com", :password => "password@1", :firstname => "Test", :lastname => "Rails")
     user.save
     post = Post.new(:title => "T1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :user => user)
     post.save
     post.reload
     post.readable_categories.should == "category1, category2"
  end
  
  it "should not allow comments if the post is over 14 days old" do
     post = Post.new(:title => "T1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :created_at => (DateTime.now - 15))

     post.allow_comments?.should be_false
  end
  
  it "should allow comments if the post is under 14 days old" do
     post = Post.new(:title => "T1", :body => "bd1", :tags => "tag1, tag2", :categories => "category1, category2", :created_at => (DateTime.now - 13))

     post.allow_comments?.should be_true
  end
  
  
end