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

after "deploy:restart", "resque:restart"

# Voupe Deploy tracking
set :dashboard_site_uuid, "20571dab-b87e-4c46-9b04-9ae9625a75f5"
 
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

	task :secret_token, roles: :app, except: {no_release: true} do
		run "ln -nfs #{shared_path}/config/secret_token.yml #{release_path}/config/secret_token.yml"
	end
end

after "mysql:symlink", "symlink:stripe_connect"
after "mysql:symlink", "symlink:omniauth"
after "mysql:symlink", "symlink:secret_token"