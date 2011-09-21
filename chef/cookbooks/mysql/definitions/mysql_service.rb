define :mysql_service do

  mysql_name="mysql-#{params[:name]}"

  service mysql_name do
    if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
      restart_command "restart #{mysql_name}"
      stop_command "stop #{mysql_name}"
      start_command "start #{mysql_name}"
      status_command "status #{mysql_name} | cut -d' ' -f2 | cut -d'/' -f1 | grep start"
    end
    supports :status => true, :restart => true
    action [:enable, :start]
    subscribes :restart, resources(:template => node[:mysql][:config_file])
  end

end
