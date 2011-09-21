name "mysql-server"
description "Mysql Server Role"
run_list(
         "recipe[mysql::server]"
)
default_attributes()
override_attributes()

