name "mysql-client"
description "Mysql Client Role"
run_list(
         "recipe[mysql::client]",
         "recope[mysql::test]"
)
default_attributes()
override_attributes()

