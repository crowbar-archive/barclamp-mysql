#
# Copyright 2011, Dell
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
#
# Author: andi abes
#

####
# if monitored by nagios, install the nrpe commands

# Node addresses are dynamic and can't be set from attributes only.
node[:mysql][:monitor][:ports]["mysql-api"] = [node[:mysql][:api_bind_host], node[:mysql][:api_bind_port]]

svcs = node[:mysql][:monitor][:svcs]
ports = node[:mysql][:monitor][:ports]
log ("will monitor mysql svcs: #{svcs.join(',')} and ports #{ports.values.join(',')}")

template "/etc/nagios/nrpe.d/mysql_nrpe.cfg" do
  source "mysql_nrpe.cfg.erb"
  mode "0644"
  group node[:nagios][:group]
  owner node[:nagios][:user]
  variables( {
    :svcs => svcs ,
    :ports => ports
  })    
   notifies :restart, resources(:service => "nagios-nrpe-server")
end if node["roles"].include?("nagios-client")    

