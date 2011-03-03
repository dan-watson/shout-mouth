require File.dirname(__FILE__) + '/../app/lib/fixnum.rb'

require 'rspec'

describe "library extentions" do
  it "Fixnum ordinalize should give the correct ordinalization for the date in a month" do
    1.ordinalize.should == "1st"
    2.ordinalize.should == "2nd"
    3.ordinalize.should == "3rd"
    4.ordinalize.should == "4th"
    15.ordinalize.should == "15th"
    31.ordinalize.should == "31st"
  end
end