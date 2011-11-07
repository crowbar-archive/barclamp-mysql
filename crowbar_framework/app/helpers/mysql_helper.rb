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
# 
module MysqlHelper


  def mysql_instance_selector(name, field, proposal)
    service = MysqlService.new nil
    options = service.list_active[1]
    if options.empty?
      options = [["None", ""]]
    else 
      options = options.map { |x| [x,x] }
    end

    def_val = proposal.raw_data['attributes'][proposal.barclamp][field] || ""

    select_tag name, options_for_select(options, def_val), :onchange => "update_value(#{field}, #{field}, 'string')"
  end

end
