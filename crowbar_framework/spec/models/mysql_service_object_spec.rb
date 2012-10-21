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

end




