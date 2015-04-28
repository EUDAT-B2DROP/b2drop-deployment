# On the node you want to use, just add b2drop by
include ::b2drop
# and configure some of the involved modules ia hiera by:

# HIERA:
######## mysql
mysql::server::remove_default_accounts: true,
######## owncloud
owncloud::db_pass: 'somesecretpass'
owncloud::datadirectory: '/owncloud/data'