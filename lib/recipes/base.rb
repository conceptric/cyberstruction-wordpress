namespace :deploy do
  
  after "deploy:setup", "deploy:additional_directories"
  after "deploy:setup", "deploy:setup_database"
  after "deploy:symlink",  "deploy:finalize_symlinks"

  # Create the additional directories
  task :additional_directories do
    wordpress.setup_uploads_directory
    wordpress.set_ownership
  end   
  
  # Setup the mysql database and the wordpress config file
  task :setup_database do
    mysql.create_database
    wordpress.mysql.config    
  end
    
  # Complete the symbolic linking and setting permissions
  task :finalize_symlinks do
    wordpress.configure_and_link
  end
  
  task :migrate do
    # Do nothing
    run "echo 'Database migration override!'"
  end
  
  desc "Deploy an updated version of the Apache vhost file"
  task :vhost do
    wordpress.apache.add_apache_vhost
    apache.enable_application
  end
  
  # Override the default start task for cold deployment
  task :start do
    deploy.vhost
    run "echo 'Application activated!'"
  end
  
  # Override the default restart task
  task :restart do
    run "echo 'Backing up the database before restart'"
    # management.database.archive_to_current
    # Do nothing
    run "echo 'Nothing restarted!'"
  end 
    
end