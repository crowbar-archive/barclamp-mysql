name "mysql-test"
description "Mysql Client Role"
run_list(
         "recipe[mysql::client]",
         "recipe[mysql::test]"
)
default_attributes()
override_attributes()

