require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'


describe "Plugin Factory Class" do
  
  before(:all) do
    PluginFactory.instance
  end
   
 it "should load all classes from each folder by convention - ie folder twitter will contain twitter_plugin.rb" do
   TwitterPlugin.new.nil?.should == false
 end
 
 it "should be able to return a choosen plugin class" do
   PluginFactory.instance.get_plugin(:twitter).respond_to?("data").should be_true
 end
 
end

describe "Plugin Class" do

  it "should return the correct data for the plugin" do
    PluginFactory.instance.get_plugin(:twitter).data.should ==  Blog.twitter_account
  end
  
  it "should return the correct plugin name" do
    PluginFactory.instance.get_plugin(:twitter).plugin_name.should == "twitter"
  end
  
  it "should return the correct view directory name" do
    PluginFactory.instance.get_plugin(:twitter).view_directory.should include("/twitter/view/")
  end
  
  it "should return the correct view name" do
    PluginFactory.instance.get_plugin(:twitter).view_name.should == "twitter_plugin"
  end
end


describe "Twitter Plugin" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end
  it "should display on the home page" do
    get '/'
    last_response.body.should include Blog.twitter_account
  end
end