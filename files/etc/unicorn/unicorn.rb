# amount of unicorn workers to spin up
worker_processes 2

# App location
@app = Dir.pwd

## Help ensure your application will always spawn in the symlinked
## # "current" directory that Capistrano sets up.
#working_directory "#{@app}" # available in 0.94.0+

## Listen on fs socket for better performance
listen "#{@app}/tmp/sockets/unicorn.sock", :backlog => 64

## Nuke workers after 30 seconds instead of 60 seconds (the default)
#timeout 30

## App PID
pid "#{@app}/tmp/pids/unicorn.pid"

## By default, the Unicorn logger will write to stderr.
## Additionally, some applications/frameworks log to stderr or stdout,
## so prevent them from going to /dev/null when daemonized here:
stderr_path "#{@app}/log/unicorn.stderr.log"
stdout_path "#{@app}/log/unicorn.stdout.log"

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# # http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true

# Enable this flag to have unicorn test client connections by writing the
# beginning of the HTTP headers before calling the application.  This
# prevents calling the application for connections that have disconnected
# while queued.  This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection false

# Force the bundler gemfile environment variable to
# reference the Сapistrano "current" symlink
#before_exec do |_|
  #ENV["BUNDLE_GEMFILE"] = File.join(@app, 'Gemfile')
#end

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
