#
# Cookbook Name:: glance
# Recipe:: api
#
#

include_recipe "#{@cookbook_name}::common"

mysql_service "api"

node[:mysql][:monitor][:svcs] <<["mysql-api"]

