# -*- mode: ruby -*-
# vi: set ft=ruby :

# General project settings
#################################

  # IP Address for the host only network, change it to anything you like
  # but please keep it within the IPv4 private network range
  ip_address = "10.2.2.2"

  # The project name is base for directories, hostname and alike
  project_name = "symfony"

  # MySQL and PostgreSQL password - feel free to change it to something
  # more secure (Note: Changing this will require you to update the index.php example file)
  database_password = project_name

# Vagrant configuration
#################################

  Vagrant.configure("2") do |config|
    # Enable Berkshelf support
    config.berkshelf.enabled = true

    # Use the omnibus installer for the latest Chef installation
    config.omnibus.chef_version = :latest

    # Define VM box to use
    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"

    # Set share folder
    config.vm.synced_folder "./" , "/opt/vagrant/", :mount_options => ["dmode=777", "fmode=775"]

    # Use hostonly network with a static IP Address and enable
    # hostmanager so we can have a custom domain for the server
    # by modifying the host machines hosts file
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.vm.define project_name do |node|
      node.vm.hostname = project_name + ".vm"
      node.vm.network :private_network, ip: ip_address
      #node.hostmanager.aliases = [ project_name + ".vm" ]
    end
    config.vm.provision :hostmanager

    # Enable and configure chef solo
    config.vm.provision :chef_solo do |chef|
      chef.add_recipe "app::packages"
      chef.add_recipe "app::web_server"
      chef.add_recipe "app::vhost"
      chef.add_recipe "memcached"
      chef.add_recipe "app::db"
      chef.json = {
        :app => {
          # Project name
          :name           => project_name,

          # Name of MySQL database that should be created
          :db_name        => project_name,

          # Server name and alias(es) for Apache vhost
          :server_name    => project_name + ".vm",
          :server_aliases =>  [ "www." + project_name + ".vm" ],

          # Document root for Apache vhost
          :docroot        => "/var/vhosts/" + project_name + "/web",

          # General packages
          :packages   => %w{ vim git screen curl acl git mcrypt mysql-server nodejs npm sendmail python-software-properties },
          
          # PHP packages
          :php_packages   => %w{ php-apc php5-curl php5-dev php5-gd php5-intl libicu-dev php5-mcrypt php5-memcached php5-mysql phpmyadmin }

        },
        :mysql => {
          :server_root_password   => database_password,
          :server_repl_password   => database_password,
          :server_debian_password => database_password,
          :bind_address           => ip_address,
          :allow_remote_root      => true
        }
      }
    end
  end