require 'rspec'
require File.dirname(__FILE__) + '/../models/post'

describe Post, "validation" do
  it "should not be valid if the title and body are not present" do
    post = Post.new
    post.should_not be_valid
  end
  
  it "should be valid if the required fields are supplied correctly" do
    post = Post.new(:title => "T1", :body => "bd1")
    post.should be_valid
  end
end
