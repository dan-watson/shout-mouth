require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'

describe "category factory methods" do
  
  before(:all) do
    TestDataHelper.wipe_database
  end
  
  it "categories_from_array should create a collection of category objects from an array" do
      categories = Category.categories_from_array(["category99", "category100"])
      categories.count.should == 2
      Category.all.count.should == 2
  end
  
  after(:all) do
    TestDataHelper.wipe_database
  end
end