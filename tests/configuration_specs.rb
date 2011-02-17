require File.dirname(__FILE__) + '/../shout_mouth.rb'

require 'rspec'


describe Blog, "configuration" do
  it "should return the correct configuration variable for the Url" do
    Blog.url.should == "http://127.0.0.1:9393"
  end
  
  it "should return the correct configuration variable for the askimet key" do
    Blog.akismet_key.should == "123456789"
  end
  
  it "should return the correct configuration variable for the site_name key" do
    Blog.site_name.should == "Test Site"
  end
end