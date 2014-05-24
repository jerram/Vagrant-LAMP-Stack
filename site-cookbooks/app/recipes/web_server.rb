#
# Cookbook Name:: app
# Recipe:: web_server
#
# Copyright 2013, Mathias Hansen
#
	
# Install Apache
include_recipe "openssl"
include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"

# Install PHP
#include_recipe "dotdeb"
#include_recipe "dotdeb::php54"
#include_recipe "php"

# Use PHP 5.4
# sudo add-apt-repository ppa:ondrej/php5
apt_repository "php54" do
uri "http://ppa.launchpad.net/ondrej/php5-oldstable/ubuntu"
distribution node['lsb']['codename']
components ["main"]
keyserver "keyserver.ubuntu.com"
key "E5267A6C"
end

# Use NodeJS 0.10.28
# sudo apt-add-repository -y ppa:chris-lea/node.js
apt_repository "nodejs" do
uri "http://ppa.launchpad.net/chris-lea/node.js/ubuntu"
distribution node['lsb']['codename']
components ["main"]
keyserver "keyserver.ubuntu.com"
key "C7917B12"
end

include_recipe "apt"

# Install PHP5 packages
node['app']['php_packages'].each do |a_package|
  package a_package
end

# Fix deprecated comments in PHP ini files by replacing '#' with ';'
bash "fix-phpcomments" do
  code "find /etc/php5/cli/conf.d/ -name '*.ini' -exec sed -i -re 's/^(\\s*)#(.*)/\\1;\\2/g' {} \\;"
  notifies :restart, resources("service[apache2]"), :delayed
end

# Install LESS
#bash "less" do
#  code <<-EOH
  #sudo apt-get update & sudo apt-get upgrade -y
  #touch /home/vagrant/.npmrc
  #mkdir /home/vagrant/.local
  #chown vagrant:vagrant /home/vagrant/.npmrc
  #chown vagrant:vagrant /home/vagrant/.local
  #echo 'registry = "http://registry.npmjs.org/"' | tee -a /home/vagrant/.npmrc
  #sudo npm install -g less
#  EOH
#end

# Install Composer
bash "composer" do
  code <<-EOH
    curl -s https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
  EOH
end

# Prepare web root
bash "webroot" do
  code <<-EOH
    sudo mkdir -p /var/vhosts/symfony/web
    echo 'symfony folders set up' | sudo tee -a /var/vhosts/symfony/web/index.html
    sudo chown www-data:www-data -R /var/vhosts
  EOH
end
