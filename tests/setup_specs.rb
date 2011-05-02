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
    #delete database so the application is tricked into thinking its a new instance.
    FileUtils.rm_rf(File.expand_path("../../db/shout_mouth.db", __FILE__))
  end

  after(:all) do
    #Reset settings back to test defaults
    DataMapper.auto_upgrade!
    TestDataHelper.settings  
  end

  it "should render the setup page when the setup flag is true and the database does not exist" do
    get '/' 
    last_response.body.should include "Shout Mouth Setup"
  end

end
