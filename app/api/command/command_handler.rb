class CommandHandler
  
  def initialize
    @command = nil
  end
  
  def register_command command 
    @command = command 
  end
  
  def execute
    #validation classes should return :invalid, :valid or an array of errors
    #will load the validation class with the same name as the command class if it exists eg SetupCommand = SetupValidator
    #take the name of the command SetupCommand = setup
    command_name = @command.class.to_s.gsub(/^.*?(?=Command)/).first.downcase
    #run the validator and capture the response
    response = run_validator_for_command command_name
    #return the validation messages if the class is not valid
    return response unless response == :valid
    #execute the command
    @command.execute
  end
  
  private 
  def get_validators_directory
     #directory of the validators
     settings.root + "/validators/"
  end
  
  def run_validator_for_command name
    #go hunting for a NamedValidator in the validators directory
    validator = "#{get_validators_directory}#{name}_validator.rb"
    #load the matching validator if it exists
    require validator if File.exists? validator 
    
    begin
      #run the validator
      return Object::const_get("#{name.capitalize}Validator").new.validate(@command.settings)
    rescue NameError => e
      #no validation class is avaliable for the command so convention states validation is not necessary
      return :valid
    end
    :invalid
  end
end
