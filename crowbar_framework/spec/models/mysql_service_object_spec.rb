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

require 'spec_helper'

describe "MysqlServiceObject" do
  
  before(:each) do
    @barclamp = Barclamp.find_by_name("mysql")
    @service_object = @barclamp.operations
  end
  
  #
  # Create proposal is an overriden routine. Parameters are already validated.
  #
  describe "Create Proposal" do
    it "should create a proposal with no nodes" do
      answer = @service_object.create_proposal("fred")
      answer.should be_an_instance_of Proposal
      node_roles = NodeRole.find_all_by_proposal_config_id(answer.current_config.id)
      node_roles.length.should be 0
    end

    it "should create a proposal with no nodes if the only node is an admin node" do
      n = Node.new
      n.name = "admin.dell.com"
      n.admin = true
      n.save!

      answer = @service_object.create_proposal("fred")
      answer.should be_an_instance_of Proposal
      node_roles = NodeRole.find_all_by_proposal_config_id(answer.current_config.id)
      node_roles.length.should be 0
    end

    it "should create a proposal with one node" do
      n = Node.new
      n.name = "admin.dell.com"
      n.admin = true
      n.save!
      n = Node.new
      n.name = "other.dell.com"
      n.save!

      answer = @service_object.create_proposal("fred")
      answer.should be_an_instance_of Proposal
      node_roles = NodeRole.find_all_by_proposal_config_id(answer.current_config.id)
      node_roles.length.should be 1
      node_roles[0].node.id.should be n.id
    end

  end

  describe "Apply Role Pre Chef Call" do
    # It should never touch the old_config, always send nil in these tests

    it "should do nothing if no nodes are provided" do
      new_config = mock(Proposal)
      new_config.should_receive(:active_config).exactly(0).times
      new_config.should_receive(:config_hash).exactly(0).times
      @service_object.apply_role_pre_chef_call(nil, new_config, [])
    end

    def setup_prop_config_mock()
      addr1 = mock(IpAddress)
      addr1.should_receive(:addr).exactly(1).times.and_return("1.1.1.1")
      addr2 = mock(IpAddress)
      addr2.should_receive(:addr).exactly(1).times.and_return("2.2.2.2")
      n1 = mock(Node)
      n1.should_receive(:address).exactly(1).times.and_return(addr1)
      n2 = mock(Node)
      n2.should_receive(:address).exactly(1).times.and_return(addr2)
      nodes = [ n1, n2 ]

      ac = mock(ProposalConfig)
      ac.should_receive(:get_nodes_by_role).exactly(1).times.and_return([])
      ac.should_receive(:get_node_config_hash).and_return({:mysql => {}}, {})
      ac.should_receive(:set_node_config_hash).exactly(2).times do |arg1, arg2|
        arg2[:mysql][:api_bind_host].should eq(arg1 == n1 ? "1.1.1.1" : "2.2.2.2")
      end
      [ac, nodes]
    end

    it "should set api_bind_host on all nodes to the nodes admin address" do
      new_config, nodes = setup_prop_config_mock
      new_config.should_receive(:config_hash).exactly(1).times.and_return({:mysql => {}})
      new_config.should_receive(:config_hash=).exactly(1).times
      @service_object.apply_role_pre_chef_call(nil, new_config, nodes)
    end

    it "should set passwords if unset" do
      new_config, nodes = setup_prop_config_mock
      new_config.should_receive(:config_hash).exactly(1).times.and_return({:mysql => {}})
      new_config.should_receive(:config_hash=).exactly(1).times do |arg|
        arg["mysql"]["server_debian_password"].should eq("fred1")
        arg["mysql"]["server_root_password"].should eq("fred2")
        arg["mysql"]["server_repl_password"].should eq("fred3")
        arg["mysql"]["db_maker_password"].should eq("fred4")
      end
      @service_object.should_receive(:random_password).exactly(4).times.and_return("fred1", "fred2", "fred3", "fred4")

      @service_object.apply_role_pre_chef_call(nil, new_config, nodes)
    end

    it "should not set passwords if set" do
      new_config, nodes = setup_prop_config_mock
      data = { "mysql" => {
        "server_debian_password" => "greg1",
        "server_root_password" => "greg2",
        "server_repl_password" => "greg3",
        "db_maker_password" => "greg4" } }
      new_config.should_receive(:config_hash).exactly(1).times.and_return(data)
      new_config.should_receive(:config_hash=).exactly(1).times do |arg|
        arg["mysql"]["server_debian_password"].should eq("greg1")
        arg["mysql"]["server_root_password"].should eq("greg2")
        arg["mysql"]["server_repl_password"].should eq("greg3")
        arg["mysql"]["db_maker_password"].should eq("greg4")
      end
      @service_object.should_receive(:random_password).exactly(0).times

      @service_object.apply_role_pre_chef_call(nil, new_config, nodes)
    end

    # GREG: Add tests for mysql-client configs.

  end

end




