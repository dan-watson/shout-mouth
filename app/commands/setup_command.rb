require Dir.pwd + '/app/api/command/command'

class SetupCommand < Command
  def execute
    #Create the database
    system "rake -f rakefile.rb db:create" 

    #Time to update the settings
    @settings.each{|setting|
      begin 
       Blog.send("#{setting[0]}=", setting[1])
      rescue NoMethodError
       #Not all the passed in params are methods on the blog class
      end
    }

    Category.categories_from_array(@settings["categories"].split(",").each{|i| i.strip!})

    User.new(:email => @settings["user"]["email"], 
             :password => @settings["user"]["password"], 
             :firstname => @settings["user"]["firstname"],
             :lastname => @settings["user"]["lastname"]).save

    return true
  end
end