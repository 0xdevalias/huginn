wd = File.expand_path(File.join(File.dirname(__FILE__), '..'))

app_path = wd

worker_processes 2
preload_app true
timeout 180

#listen "#{wd}/tmp/sockets/unicorn.socket"
listen "0.0.0.0:3000", :tcp_nopush => true
# TODO: Dev hack.. might be needed for linking?

working_directory app_path

rails_env = ENV['RAILS_ENV'] || 'production'

# Log everything to one file
#stderr_path "log/unicorn.log"
#stdout_path "log/unicorn.log"
# TODO: Can we make this output to forground as well? Better for docker logs

# Set master PID location
pid "#{wd}/tmp/pids/unicorn.pid"

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
