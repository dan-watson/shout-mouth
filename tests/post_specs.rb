require 'rspec'
require File.dirname(__FILE__) + '/../models/post'

describe Post, "validation" do
  it "should not be valid if the title and body are not present" do
    post = Post.new
    post.should_not be_valid
  end
  
  it "should be valid if the required fields are supplied correctly" do
    #arrange
    user = User.new(:email => "test@rails.com", :password => "password@1")
    user.save
    post = Post.new(:title => "T1", :body => "bd1", :user => user)
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
end