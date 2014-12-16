#
# Cookbook Name:: mademedia_sendmail
# Attribute:: default
#
# Copyright 2014, Made Media Ltd.
#
# Released under the MIT license, see LICENSE
#

# Our default package list
default['mademedia_sendmail']['debian']['package_list'] = [
	'sendmail',
	'sendmail-cf',
]
default['mademedia_sendmail']['rhel']['package_list'] = [
	'sendmail',
	'sendmail-cf',
]

# Our default configuration options
## Services
default['mademedia_sendmail']['debian']['service_name'] = "sendmail"
default['mademedia_sendmail']['rhel']['service_name'] = "sendmail"
## Filesystem
default['mademedia_sendmail']['debian']['config_dir'] = '/etc/mail'
default['mademedia_sendmail']['rhel']['config_dir'] = '/etc/mail'
default['mademedia_sendmail']['owner'] = 'root'
default['mademedia_sendmail']['group'] = 'root'
default['mademedia_sendmail']['perms'] = '0640'
default['mademedia_sendmail']['access_config'] = 'access'
default['mademedia_sendmail']['sendmail_config'] = 'sendmail.mc'
default['mademedia_sendmail']['sendmail_compiled_config'] = 'sendmail.cf'
## Network
default['mademedia_sendmail']['listen_address'] = '127.0.0.1'
default['mademedia_sendmail']['local_domain'] = 'localhost.localdomain'
default['mademedia_sendmail']['relay_port'] = '587'
default['mademedia_sendmail']['mechanisms'] = 'EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN'
default['mademedia_sendmail']['masquerade'] = []
default['mademedia_sendmail']['additional'] = []

# Permissible relay hosts
default['mademedia_sendmail']['connections'] = {
	'localhost.localdomain' => 'relay',
	'localhost' => 'relay',
	'127.0.0.1' => 'relay',
}

# SMTP Authentication information details
default['mademedia_sendmail']['authinfo'] = {
	# Intentionally blank, you must supply these with at least the username, password and mechanism.
	# Here is an example:
	
	# 'hostname' => {
	# 	'username' => 'marco@polo.com',
	# 	'password' => 'venice',
	# 	'mechanisms' => 'plain',
	# 	'authentication' => NULL,
	# 	'realm' => NULL,
	# 	'relay' => true,
	# 	'port' => NULL
	# }
}
