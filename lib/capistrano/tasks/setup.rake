namespace :setup do

  desc "Upload database.yml file."
  task :upload_yml do
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(File.read("config/database.yml")), "#{shared_path}/config/database.yml"
      upload! StringIO.new(File.read("config/secrets.yml")), "#{shared_path}/config/secrets.yml"
      upload! StringIO.new(File.read("config/railsapp_vhost.conf")), "#{shared_path}/config/railsapp_vhost.conf"
      upload! StringIO.new(File.read("config/puma.rb.sample")), "#{shared_path}/config/puma.rb"
    end
  end

  desc "Seed the database."
  task :seed_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "db:seed"
        end
      end
    end
  end

  desc "Symlinks config file for Nginx."
  task :symlink_config do
    on roles(:app) do
      execute "rm -f /etc/nginx/sites-enabled/default"
      execute "ln -nfs #{shared_path}/config/railsapp_vhost.conf /etc/nginx/sites-enabled/#{fetch(:application)}_vhost.conf"
   end
  end

  desc "Restart Nginx."
  task :restart_nginx do
    on roles(:web) do
      execute "sudo /etc/init.d/nginx restart"
   end
  end


end
