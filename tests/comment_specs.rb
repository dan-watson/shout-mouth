require File.dirname(__FILE__) + '/../shout_mouth.rb'

require 'rspec'
require 'akismetor'

describe Comment, "validation" do
  it "should not be valid if the email address and comment are not present" do
    comment = Comment.new
    comment.should_not be_valid
  end
  
  it "should not be valid if the email address given is not a valid email address" do
    comment = Comment.new(:comment_author_email => "hkln/c/.com")
    comment.should_not be_valid
  end
  
  it "should be valid if the required fields and email address are supplied correctly" do
    comment = Comment.new(:comment_author_email => "test@rails.com", :comment_content => "cm1", 
                          :comment_author => "Mr Ham Ok", :comment_author_url => "http://myblog.com")
    comment.should be_valid
  end
end

describe Comment, "defaults" do
  it "should have the active flag set to true" do
    comment = Comment.new(:comment_author_email => "test@rails.com", :comment_content => "cm1", 
                          :comment_author => "Mr Ham Ok", :comment_author_url => "http://myblog.com")
    comment.is_active.should be_true
  end
  
  it "should have the created_at date and time set" do
    comment = Comment.new(:comment_author_email => "test@rails.com", :comment_content => "cm1", 
                          :comment_author => "Mr Ham Ok", :comment_author_url => "http://myblog.com")
    comment.created_at.should_not be_nil
  end
end

describe Comment, "spam checker" do
  
    before(:all) do
      user = User.new(:email => "test@rails.com", :password => "password@1")
      user.save
      @post = Post.new(:title => "T1", :body => "bd1", :user => user)
      @post.save
    end
    
    it "should return spam if the author name is viagra-test-123" do
      
      #arrange
      Akismetor.should_receive(:spam?).and_return(true)

      comment = Comment.new(:comment_author_email => "test@rails.com", :comment_content => "This is a test.", 
                            :comment_author => "viagra-test-123", :comment_author_url => "http://myblog.com",
                            :user_ip => "127.0.0.1", :user_agent => "Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10.5; en-US; rv:1.9.0.3) Gecko/2008092414 Firefox/3.0.3",
                            :referrer => "http://google.com", :post => @post)
                          
      comment.save
      comment.is_spam?.should be_true
              
    end
    
    it "should return ham if the comment is valid" do
      
      #arrange
      Akismetor.should_receive(:spam?).and_return(false)

      comment = Comment.new(:comment_author_email => "test@rails.com", :comment_content => "This is a test.", 
                            :comment_author => "Mr Ham", :comment_author_url => "http://myblog.com",
                            :user_ip => "127.0.0.1", :user_agent => "Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10.5; en-US; rv:1.9.0.3) Gecko/2008092414 Firefox/3.0.3",
                            :referrer => "http://google.com", :post => @post)
                          
      comment.save
      comment.is_spam?.should be_false
              
    end
end