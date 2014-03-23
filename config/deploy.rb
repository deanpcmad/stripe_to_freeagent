# =============================================================================
# GENERAL SETTINGS
# =============================================================================

## Set the name for the application
set :application, "stripe_to_freeagent"

## Path where the application should be stored
set :deploy_to, "/opt/apps/stripe_to_freeagent"

## Repository settings
set :repository, "git@github.com:voupe/stripe_to_freeagent.git"
set :branch, "master"

## Server/app details
server "87.117.253.86", :web, :app, :db, primary: true
set :domain_name, "stripetofreeagent.com"
 
role :resque_worker, "87.117.253.86"
role :resque_scheduler, "87.117.253.86"
set :workers, { "*" => 2 }
set :resque_environment_task, true

after "deploy:restart", "resque:restart"
 
# =============================================================================
# RECIPE INCLUDES
# =============================================================================
 
require "rubygems"
require "bundler/capistrano"
require "capistrano-resque"
require "capistrano-voupe"

namespace :symlink do
	task :stripe_connect, roles: :app, except: {no_release: true} do
		run "ln -nfs #{shared_path}/config/initializers/stripe_connect.rb #{release_path}/config/initializers/stripe_connect.rb"
	end

	task :omniauth, roles: :app, except: {no_release: true} do
		run "ln -nfs #{shared_path}/config/initializers/omniauth.rb #{release_path}/config/initializers/omniauth.rb"
	end
end

after "mysql:symlink", "symlink:stripe_connect"
after "mysql:symlink", "symlink:omniauth"