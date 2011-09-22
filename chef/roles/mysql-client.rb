name "mysql-client"
description "Mysql Client Role"
run_list(
         "recipe[mysql::client]"
)
default_attributes()
override_attributes()

