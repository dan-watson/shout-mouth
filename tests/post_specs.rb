require File.dirname(__FILE__) + '/../shout_mouth.rb'

require 'rspec'

describe Post, "validation" do
  it "should not be valid if the title and body are not present" do
    post = Post.new
    post.should_not be_valid
  end
  
  it "should be valid if the required fields are supplied correctly" do
    #arrange
    user = User.new(:email => "test@rails.com", :password => "password@1")
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
      post.permalink.should == "http://test.myblog.com/post/#{DateTime.now.to_date.strftime("%Y/%m/%d")}/the-wheels-on-my-bus-dont-go-round-and-round"
  end
end

describe Post, "querying" do
  before(:all) do
   valid_post = Factory(:valid_post)
   valid_post.save  
  
   inactive_post = Factory(:inactive_post)
   inactive_post.save
  
  end
  it "should not pull back inactive posts" do
    all_posts = Post.all.count
    active_posts = Post.all_active.count
    active_posts.should be < all_posts
  end
end