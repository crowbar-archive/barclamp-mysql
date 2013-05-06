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

  def create_proposal(name)
    @logger.debug("Mysql create_proposal: entering")
    base = super(name)

    node = Node.first(:conditions => [ "admin = ?", false])
    add_role_to_instance_and_node(node.name, base.name, "mysql-server") if node

    @logger.debug("Mysql create_proposal: exiting")
    base
  end

  def apply_role_pre_chef_call(old_config, new_config, all_nodes)
    @logger.debug("Mysql apply_role_pre_chef_call: entering #{all_nodes.inspect}")
    return if all_nodes.empty?

    # Find the nodes we want to be clients and servers
    server_nodes = new_config.get_nodes_by_role("mysql-server")
    @logger.debug("Mysql mysql-server elements: #{server_nodes.inspect}")
    client_nodes = new_config.get_nodes_by_role("mysql-client")
    @logger.debug("Mysql mysql-client elements: #{client_nodes.inspect}")

    # Whack a config on to them.
    all_nodes.each do |node|
      admin_address = node.address.addr
      node_hash = new_config.get_node_config_hash(node)
      node_hash[:mysql] ||= {}
      if server_nodes.member?(node)
        ["server_debian_password","server_root_password",
         "server_repl_password","db_maker_password"].each do |p|
          node_hash[:mysql][p] ||= random_password
        end
      end
      if client_nodes.member?(node) && !server_nodes.empty? &&
          !node_hash["mysql_server"]
        @logger.debug("Mysql assign node[:mysql-server] for #{node.name}")
        node_hash["mysql-server"] ||= server_nodes[0].name
      end
      node_hash[:mysql][:api_bind_host] = admin_address
      new_config.set_node_config_hash(node, node_hash)
    end
    @logger.debug("Mysql apply_role_pre_chef_call: leaving")
  end

end

