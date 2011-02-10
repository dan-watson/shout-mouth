require File.dirname(__FILE__) + '/../shout_mouth.rb'

require 'rspec'


describe Blog, "configuration" do
  it "should return the correct configuration variable for the Url" do
    Blog.url.should == "http://test.myblog.com"
  end
  
  it "should return the correct configuration variable for the askimet key" do
    Blog.akismet_key.should == "123456789"
  end
end