#
# Cookbook Name:: mysql
# Recipe:: setup
#

include_recipe "#{@cookbook_name}::common"

bash "tty linux setup" do
  cwd "/tmp"
  user "root"
  code <<-EOH
	mkdir -p /var/lib/mysql/
	curl #{node[:mysql][:tty_linux_image]} | tar xvz -C /tmp/
	touch /var/lib/mysql/tty_setup
  EOH
  not_if do File.exists?("/var/lib/mysql/tty_setup") end
end
