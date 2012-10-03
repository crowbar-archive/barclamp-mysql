# Copyright 2011, Dell 
# 
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#  http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
# 

class MysqlService < ServiceObject

  def initialize(thelogger)
    @bc_name = "mysql"
    @logger = thelogger
  end

  def self.allow_multiple_proposals?
    true
  end

  def create_proposal
    @logger.debug("Mysql create_proposal: entering")
    base = super

    nodes = NodeObject.all
    nodes.delete_if { |n| n.nil? or n.admin? }
    if nodes.size >= 1
      base["deployment"]["mysql"]["elements"] = {
        "mysql-server" => [ nodes.first[:fqdn] ]
      }
    end

    @logger.debug("Mysql create_proposal: exiting")
    base
  end

  def apply_role_pre_chef_call(old_role, role, all_nodes)
    @logger.debug("Mysql apply_role_pre_chef_call: entering #{all_nodes.inspect}")
    return if all_nodes.empty?

    # Make sure the bind hosts are in the admin network
    all_nodes.each do |n|
      node = NodeObject.find_node_by_name n

      admin_address = node.get_network_by_type("admin")["address"]
      node.crowbar[:mysql] = {} if node.crowbar[:mysql].nil?
      node.crowbar[:mysql][:api_bind_host] = admin_address

      node.save
    end

    om = old_role ? old_role.default_attributes["mysql"] : {}
    nm = role.default_attributes["mysql"]

    nm["server_debian_password"] = om["server_debian_password"] || random_password 
    nm["server_root_password"] = om["server_root_password"] || random_password
    nm["server_repl_password"] = om["server_repl_password"] || random_password
    nm["db_maker_password"] = om["db_maker_password"] || random_password
    role.save

    #identify server node
    server_nodes = role.override_attributes["mysql"]["elements"]["mysql-server"]
    @logger.debug("Mysql mysql-server elements: #{server_nodes.inspect}")
    if server_nodes.size == 1
      server_name = server_nodes.first
      @logger.debug("Mysql found single server node: #{server_name}")
      # set mysql-server attribute for any mysql-client role nodes
      cnodes = role.override_attributes["mysql"]["elements"]["mysql-client"]
      @logger.debug("Mysql mysql-client elements: #{cnodes.inspect}")
      unless cnodes.nil? or cnodes.empty?
        cnodes.each do |n|
          node = NodeObject.find_node_by_name n
          node.crowbar["mysql-server"] = server_name
          @logger.debug("Mysql assign node[:mysql-server] for #{n}")
          node.save
        end
      end
    end

    @logger.debug("Mysql apply_role_pre_chef_call: leaving")
  end

end

