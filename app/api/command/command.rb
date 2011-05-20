class Command
  attr_accessor :settings
  
  def initialize settings = {}
    @settings = settings
  end
  
  protected
  def execute
  end
end