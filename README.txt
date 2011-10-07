Welcome to the MySQL Barclamp for the Crowbar Framework project
=======================================================
_Copyright 2011, Dell_

The code and documentation is distributed under the Apache 2 license (http://www.apache.org/licenses/LICENSE-2.0.html). Contributions back to the source are encouraged.

The Crowbar Framework (https://github.com/dellcloudedge/crowbar) was developed by the Dell CloudEdge Solutions Team (http://dell.com/openstack) as a OpenStack installer (http://OpenStack.org) but has evolved as a much broader function tool. 
A Barclamp is a module component that implements functionality for Crowbar.  Core barclamps operate the essential functions of the Crowbar deployment mechanics while other barclamps extend the system for specific applications.

* This functonality of this barclamp DOES NOT stand alone, the Crowbar Framework is required * 

About this Barclamp: Mysql
-------------------------------------

This Barclamp creates a MySQL server and configures clients so that they are easily integrated with the server via Chef attributes.

To build a mysql server, simply apply a proposal with your chosen node as the mysql-server.
There's no configuration required.

The Nova barclamp has a working build that integrates with this barclamp
(Currently hosted at github.com/khudgins/barclamp-nova - use the feature-mysql-barclamp branch).

To integrate your own barclamp, see the test.rb recipe. This is NOT used in any available roles through Crowbar, but is an example for how you can use it.

The Chef recipe for the server role creates a few resources for you to use. Primarily, it creates several MySQL database users, and generates secure, random passwords for each one. These users' passwords are stored as node attributes on the mysql-server node for you to use later.

The users are:

* root: Standard mysql root account. Remote access for this user is disabled.
* debian-sys-maint: used by Ubuntu for table scrubbing and maintenance.
* db-maker: an administrative user with database and table creation rights. Use this account to create your application-specific databases and user accounts. See the test recipe for an example of use. You can access MySQL from other nodes with this account.
* repl: user with replication slave rights, for future use in master/slave HA scenarios.


Known Bugs & Issues
-------------------------------------
Due to a chef-client race condition upon provisioning nodes, there's a nasty hack in the mysql-server recipe to enforce controllable passwords and permissions for MySQL. This will be removed when the race condition in core crowbar is solved. This bug will only manifest on debconf-based Linux distributions.

HA capability is planned for both DRBD-backed Active/Passive clusters and MySQL Master-Slave replication. This has not yet been implemented.


Legals
-------------------------------------
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.