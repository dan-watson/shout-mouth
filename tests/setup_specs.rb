require File.dirname(__FILE__) + '/test_data/test_data_helper.rb'
require 'fileutils'
require 'dm-core'
require 'dm-migrations'
require File.dirname(__FILE__) + '/../app/shout_mouth.rb'

describe "blog setup" do
  include Rack::Test::Methods
  
  def app
    ShoutMouth
  end

  before(:all) do
    Blog.repository.adapter.execute("DROP TABLE settings;")
  end

  after(:all) do
    #Reset settings back to test defaultsI
    DataMapper.auto_migrate!
    TestDataHelper.settings  
  end

  it "should render the setup page when the setup flag is true and the database does not exist" do
    get '/' 
    last_response.body.should include "Shout Mouth Setup"
  end

end
