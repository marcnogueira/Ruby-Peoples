require 'bundler/capistrano'

set :application, "174.122.137.40"
set :user, "marcelo"
set :repository, "git@github.com:reloadbrazil/Ruby-Peoples.git"

set :use_sudo, true
set :deploy_to, "/home/#{user}/rails_peoples"
set :scm, :git

set :bundle_without,  [:development, :test]
set :bundle_gemfile,      "Gemfile"
set :bundle_dir,          fetch(:shared_path)+"/bundle"
set :bundle_flags,       "--deployment --quiet"
set :bundle_without,      [:development, :test]

server application, :app, :web, :db, :primary => true

after 'deploy:update_code' do
  run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"
end

namespace :deploy do
  task :start do
  end
  task :stop do
  end
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    set :bundle_dir, File.join(release_path, 'vendor', 'bundle')

    shared_dir = File.join(shared_path, 'bundle')
    run "rm -rf #{bundle_dir}"
    run "mkdir -p #{shared_dir} && ln -s #{shared_dir} #{bundle_dir}"
  end

  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} ; bundle install --deployment --without development test"
  end
end