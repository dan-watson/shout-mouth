require 'rspec'
require File.dirname(__FILE__) + '/../models/comment'

describe Comment, "validation" do
  it "should not be valid if the email address and comment are not present" do
    comment = Comment.new
    comment.should_not be_valid
  end
  
  it "should not be valid if the email address given is not a valid email address" do
    comment = Comment.new(:email => "hkln/c/.com")
    comment.should_not be_valid
  end
  
  it "should be valid if the required field and email address are supplied correctly" do
    comment = Comment.new(:email => "test@rails.com", :comment => "cm1")
    comment.should be_valid
  end
end
