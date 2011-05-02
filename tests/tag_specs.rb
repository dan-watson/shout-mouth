require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

describe "tag factory methods" do
  
  before(:all) do
    TestDataHelper.wipe_database
  end
  
  it "tags_from_array should create a collection of tag objects from an array" do
      tags = Tag.tags_from_array(["tag99", "tag100"])
      tags.count.should == 2
      Tag.all.count.should == 2
  end
  
  after(:all) do
    TestDataHelper.wipe_database
  end
end
