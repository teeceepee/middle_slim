# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'middle_slim'
set :repo_url, 'https://github.com/teeceepee/middle_slim'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

## Add after init

# config for capistrano-bundler
set :bundle_bins, fetch(:bundle_bins, []).push('middleman')

# config for capistrano-rbenv
set :rbenv_ruby, '2.3.0'
set :rbenv_map_bins, fetch(:rbenv_map_bins, []).push('middleman')

# config for capistrano-nvm
set :nvm_type, :user
set :nvm_node, 'v5.10.1'
set :nvm_map_bins, fetch(:nvm_map_bins, []).push('middleman')

desc "Foo"
task :foo do
  on roles(:all) do
    within release_path do
      # puts "bundler #{fetch(:bundle_bins)}"
      # puts "rbenv #{fetch(:bundle_bins)}"
      # execute :echo, '$PATH'
      # # execute :middleman, 'version'
    end
  end
end

desc "Report Uptimes"
task :uptime do
  on roles(:all) do |host|
    info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
  end
end

set :tarball_name, 'build.tar.gz'

desc 'Deploy with local tarball'
task 'tarball_deploy' do
  # compress
  sh %(bin/middleman build)
  # sh %(scp -r build/ #{fetch(:server)}:#{release_path})

  # upload tarball
  tarball_name = 'build.tar.gz'
  sh %(tar -czf #{tarball_name} build/)
  sh %(scp #{tarball_name} #{fetch(:server)}:#{release_path})

  # uncompress tarball remotely
  on roles(:all) do
    within release_path do
      execute :tar, '-xvf', fetch(:tarball_name)
    end
  end
end

desc 'Extract tarball'
task 'extract' do
  on roles(:all) do
    within release_path do
      execute :tar, '-xvf', fetch(:tarball_name)
    end
  end
end

desc 'Build'
task 'build' do
  on roles(:all) do
    within current_path do
      execute :middleman, 'build'
    end
  end
end

after 'deploy:finished', 'build'
