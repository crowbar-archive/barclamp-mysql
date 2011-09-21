name "mysql-server"
description "Mysql Server Role"
run_list(
         "recipe[mysql::server]",
         "recipe[mysql::monitor]"
)
default_attributes()
override_attributes()

