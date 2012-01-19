namespace :wordpress do
  
  namespace :apache do
    
    desc "Add a Wordpress Apache vhost configuration file" 
    task :add_apache_vhost do
      wordpress_template_root = File.expand_path('../../templates', __FILE__)
      template_name = "apache_vhost_wordpress_template.erb"
      template = File.read("#{wordpress_template_root}/#{template_name}")
      buffer = ERB.new(template).result(binding)
      put buffer, "#{shared_path}/config/httpd.conf", :mode => 0755
      sudo "cp #{shared_path}/config/httpd.conf #{apache_vhost_available_path}"
      run "rm -f #{shared_path}/config/httpd.conf"
    end
    
  end
  
  namespace :mysql do
     
    desc "Add a wordpress mysql configuration file for production"
    task :config, :roles => [:db] do                         
      wordpress_template_root = File.expand_path('../../templates', __FILE__)
      template_name = "wp-config.php.erb"
      template = File.read("#{wordpress_template_root}/#{template_name}")
      buffer = ERB.new(template).result(binding)
      put buffer, "#{shared_path}/config/wp-config.php", :mode => 0755     
    end 
    
    desc "Link the mysql configuration file"
    task :link_config, :roles => [:web] do
      sudo "ln -nfs #{shared_path}/config/wp-config.php #{current_path}/public/wp-config.php"
    end
                                    
  end     
  
  # Create the shared uploads directory
  task :setup_uploads_directory, :roles => [:web] do
    sudo "mkdir #{shared_path}/uploads"
    sudo "chmod 777 #{shared_path}/uploads"
    sudo "mkdir #{shared_path}/assets"
    sudo "touch #{shared_path}/assets/sitemap.xml"
    sudo "touch #{shared_path}/assets/sitemap.xml.gz"
    sudo "chmod -R 777 #{shared_path}/assets"
  end

  # Set the deployment directory owner
  task :set_ownership, :roles => [:web] do
    sudo "chown -R #{domain_user}:#{domain_user} #{deploy_to}"
  end

  desc "Build the basic WordPress install in public"
  task :build do
    run "cd #{deploy_to}/current && bundle exec rake RACK_ENV='production' build_wordpress"
    run "cd #{deploy_to}/current && bundle exec rake RACK_ENV='production' add_trimmings"
    run "echo 'WordPress built'"
  end

  # Copy the configuration file to the public directory
  task :configure_and_link, :roles => [:web] do
    build 
    mysql.link_config
    link_to_uploads
    link_to_assets
  end

  # Setup the links to the shared uploads
  task :link_to_uploads, :roles => [:web] do
    transaction do
      sudo "ln -s #{shared_path}/uploads #{current_path}/public/wp-content/uploads"
      sudo "ln -s #{shared_path}/uploads #{current_path}/public/uploads"
      set_uploads_links_permissions
    end
  end

  # Setup the links to the shared assets
  task :link_to_assets, :roles => [:web] do
    transaction do
      sudo "ln -s #{shared_path}/assets/sitemap.xml #{current_path}/public/sitemap.xml"
      sudo "ln -s #{shared_path}/assets/sitemap.xml.gz #{current_path}/public/sitemap.xml.gz"
      set_sitemap_permissions
    end
  end

  # Setup uploads link ownership and permissions
  task :set_uploads_links_permissions, :roles => [:web] do
    sudo "chown -h  #{user}:#{user} #{current_path}/public/wp-content/uploads"
    sudo "chown -h  #{user}:#{user} #{current_path}/public/uploads"
    sudo "chmod 777 #{current_path}/public/wp-content/uploads"
    sudo "chmod 777 #{current_path}/public/uploads" 
  end

  # Setup sitemap file permissions
  task :set_sitemap_permissions, :roles => [:web] do
    sudo "chown -h  #{user}:#{user} #{current_path}/public/sitemap.xml"
    sudo "chmod 666 #{current_path}/public/sitemap.xml"
    sudo "chown -h  #{user}:#{user} #{current_path}/public/sitemap.xml.gz"
    sudo "chmod 666 #{current_path}/public/sitemap.xml.gz"
  end
  
end