#
# Cookbook Name:: mysql
# Recipe:: test
#
# Copyright 2008-2011, Keith Hudgins.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "mysql::client"


db_server = search(:node, "role:mysql-server")

mysql_database "create test database" do
  host "#{db_server[0].ipaddress}"
  username "db_maker"
  password "#{db_server[0].mysql.db_maker_password}"
  database "test_db"
  action :create_db
end
Chef::Log.info "pwgimme:  #{node[:mysql][:db_maker_password]}"
Chef::Log.info "pwgimme:  #{db_server[0].mysql.db_maker_password}"

# The stanza below does not work. Yet.

#mysql_database "create test database user" do
#  host "#{db_server[0].ipaddress}"
#  username "db_maker"
#  password "#{db_server[0].mysql.db_maker_password}"
#  database "test_db"
#  action :query
#  query "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON *.* TO 'test_user'@'%' IDENTIFIED BY '#{db_server[0].mysql.db_maker_password}' WITH GRANT OPTION;"
#end


#mysql_database "create application_production database" do
#  host "localhost"
#  username "root"
#  password node[:mysql][:server_root_password]
#  database "application_production"
#  action :create_db
#end