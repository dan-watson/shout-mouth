require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

describe Post, "validation" do
  it "should not be valid if the title and body are not present" do
    post = Post.new
    post.should_not be_valid
  end
  
  it "should be valid if the required fields are supplied correctly" do
    TestDataHelper.valid_post.should be_valid
  end
  
  it "should not be valid when trying to add a second post with the same title" do
    cloned_post = TestDataHelper.valid_post.attributes.keep_if{|attribute| attribute != :id}
    post = Post.new(cloned_post)
    post.valid?.should be_false
    post.errors.full_messages.should include ("Title is already taken")
  end
  
end

describe Post, "defaults" do
  it "should have the active flag set to true" do
    TestDataHelper.valid_post.should be_true
  end
  
  it "should have the created_at date and time set" do
    TestDataHelper.valid_post.created_at.should_not be_nil
  end
  
  it "should have the is_page value set to false" do
    TestDataHelper.valid_post.is_page.should be_false
  end
  
  it "should have the month and year property set after saving" do
    post = TestDataHelper.valid_post
    post.year.should == post.created_at.year
    post.month.should == post.created_at.strftime("%B")
  end

end

describe Post, "slug" do
    it "should change the title to a valid url string" do
      #Title = This is how we roll
      TestDataHelper.valid_post.slug.should == "this-is-how-we-roll"
    end
end

describe Post, "permalink" do
  it " should join the blog url and slug correctly" do
    TestDataHelper.valid_post.permalink.should == "#{Blog.url}/post/#{TestDataHelper.valid_post.created_at.strftime("%Y/%m/%d")}/this-is-how-we-roll"
  end
  
  it "should persist the slug to the database" do
    TestDataHelper.valid_post.persisted_slug.should == TestDataHelper.valid_post.slug
  end
end

describe Post, "helper methods" do
  it "should give the correct human readable date" do
     Post.new(:created_at => Date.new(2010,01,01)).readable_date.should == "Friday, 1st January, 2010"
  end
  
  it "should give the correct author name" do
      TestDataHelper.valid_post.author.should ==  TestDataHelper.valid_user.fullname
  end
  
  it "should give the correct human readable tags" do
     TestDataHelper.valid_post.readable_tags.should == "tag1, tag2"
  end
  
  it "should give the correct human readable categories" do
     TestDataHelper.valid_post.readable_categories.should == "category1, category2"
  end
  
  it "should not allow comments if the post is over 14 days old" do
     post = TestDataHelper.valid_post
     post.created_at = DateTime.now - 15
     post.allow_comments?.should be_false
  end
  
  it "should allow comments if the post is under 14 days old" do
     post = TestDataHelper.valid_post
     post.created_at = DateTime.now - 13
     post.allow_comments?.should be_true
  end
  
  it "should allow comments if the configuration is set to 0" do
     Blog.stub!(:comments_open_for_days).and_return(0)
     post = TestDataHelper.valid_post
     post.created_at = DateTime.now - 2000
     post.allow_comments?.should be_true
  end
  
  
end