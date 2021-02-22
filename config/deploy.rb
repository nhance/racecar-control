require 'capistrano-db-tasks'

# config valid only for Capistrano 3.1
lock '3.7.1'

set :application, 'race.americanenduranceracing.com'
set :repo_url, 'git@github.com:reenhanced/aer.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :branch, 'master'

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/aer/apps/race-aer'

set :rvm_ruby_version, '2.3.1'
set :rvm_type, :system

set :ssh_options, { :forward_agent => true }

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/deploy public/laptimes}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

### Capistrano db tasks config
  # if you want to remove the local dump file after loading
  set :db_local_clean, true

  # if you want to remove the dump file from the server after downloading
  set :db_remote_clean, true

  # if you are highly paranoid and want to prevent any push operation to the server
  set :disallow_pushing, true
###

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
