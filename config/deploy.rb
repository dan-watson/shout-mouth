set :application, "shoutmouth"
set :user, "root"
set :domain, "#{user}@dotnetguy.co.uk"
set :repository, "git://github.com/dotnetguyuk/Shout-Mouth.git"
set :deploy_to, "/sites/#{application}"
set :web, "nginx"
set :web_command, '/opt/nginx'

namespace :vlad do
  require File.expand_path(File.join(File.dirname(__FILE__), "..", "rakefile.rb"))  
  
  remote_task :after_update do
    Rake::Task['cache:clear'].invoke
  end

  remote_task :deploy => [:update, :after_update, :migrate, :start_app]
end
