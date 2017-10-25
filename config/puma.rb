# Change to match your CPU core count
workers 2

# Min and Max threads per worker
threads 1, 6

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# Daemonize the server into the background.The default is “false”.
daemonize true

pidfile "#{release_path}/tmp/pids/puma.pid"
state_path "#{release_path}/tmp/pids/puma.state"

bind "unix://#{release_path}/tmp/sockets/railsapp-puma.sock"
#bind 'tcp://0.0.0.0:9292'

# Logging
stdout_redirect "#{release_path}/log/puma.stdout.log", "#{release_path}/log/puma.stderr.log", true

activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{release_path}/config/database.yml")[rails_env])
end


