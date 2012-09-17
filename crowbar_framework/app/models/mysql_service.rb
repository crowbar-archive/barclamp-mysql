# Copyright 2012, Dell 
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

  def create_proposal
    @logger.debug("Mysql create_proposal: entering")
    base = super

    nodes = Node.all
    nodes.delete_if { |n| n.nil? or n.is_admin? }
    if nodes.size >= 1
      add_role_to_instance_and_node(nodes[0].name, inst, "mysql-server")
    end

    @logger.debug("Mysql create_proposal: exiting")
    base
  end

  def apply_role_pre_chef_call(old_config, new_config, all_nodes)
    @logger.debug("Mysql apply_role_pre_chef_call: entering #{all_nodes.inspect}")
    return if all_nodes.empty?

    # Make sure the bind hosts are in the admin network
    all_nodes.each do |node|
      admin_address = node.address.addr

      chash = new_config.active_config.get_node_config_hash(node)
      chash[:mysql] = {} unless chash[:mysql]
      chash[:mysql][:api_bind_host] = admin_address
      new_config.active_config.set_node_config_hash(node, chash)
    end

    hash = new_config.config_hash
    hash["mysql"]["server_debian_password"] = random_password if hash["mysql"]["server_debian_password"].nil?
    hash["mysql"]["server_root_password"] = random_password if hash["mysql"]["server_root_password"].nil?
    hash["mysql"]["server_repl_password"] = random_password if hash["mysql"]["server_repl_password"].nil?
    hash["mysql"]["db_maker_password"] = random_password if hash["mysql"]["db_maker_password"].nil?
    new_config.config_hash = hash

    #identify server node
    server_nodes = new_config.active_config.get_nodes_by_role("mysql-server")
    @logger.debug("Mysql mysql-server elements: #{server_nodes.inspect}")
    if server_nodes.size == 1
      server_name = server_nodes.first.name
      @logger.debug("Mysql found single server node: #{server_name}")
      # set mysql-server attribute for any mysql-client role nodes
      cnodes = new_config.active_config.get_nodes_by_role("mysql-client")
      @logger.debug("Mysql mysql-client elements: #{cnodes.inspect}")
      unless cnodes.nil? or cnodes.empty?
        cnodes.each do |n|
          chash = new_config.active_config.get_node_config_hash(n)
          chash["mysql-server"] = server_name
          new_config.active_config.set_node_config_hash(n, chash)
          @logger.debug("Mysql assign node[:mysql-server] for #{n}")
        end
      end
    end

    @logger.debug("Mysql apply_role_pre_chef_call: leaving")
  end

end

