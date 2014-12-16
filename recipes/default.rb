#
# Cookbook Name:: mademedia_sendmail
# Recipe:: default
#
# Copyright 2014, Made Media Ltd.
#
# Released under the MIT license, see LICENSE
#

# Most settings are in attributes/default.rb

require 'base64'

# Set core_platform based on our platform
if !node['platform_family'].nil?
	core_platform = node['platform_family']
elsif !node['platform'].nil?
	core_platform = case node['platform']
	when "debian","ubuntu" then "debian"
	else "rhel"
	end
else
	core_platform = "rhel"
end

# Make sure we've got sendmail and required tools installed
node['mademedia_sendmail'][core_platform]['package_list'].each do |pkg|
	package "#{pkg}" do
		action :install
	end
end

# Build up our configuration files
## Permitted sources of mail
connections = '';
node['mademedia_sendmail']['connections'].each do |origin,mode|
	connections += "#{origin}\t#{mode.upcase}\n"
end
## SMTP relays
authinfo = '';
relay = '';
node['mademedia_sendmail']['authinfo'].each do |host,parameters|
	next if host.nil? # Skip this loop entry if our host is not present
	next if parameters['mechanisms'].nil? # Skip if no mechanisms found
	# Make sure IP address hosts are surrounded in square brackets
	if host =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
		host = "[#{host}]"
	end
	authinfo += "AuthInfo:#{host}"
	case parameters['mechanisms'].upcase
	when "LOGIN"
		# Base 64 encode the username and password
		authinfo += " \"U=" + Base64.encode64(parameters['username']).gsub(/\n/, '') unless parameters['username'].nil?
		authinfo += " \"P=" + Base64.encode64(parameters['password']).gsub(/\n/, '') unless parameters['password'].nil?
		authinfo += " \"M:#{parameters['mechanisms']}\""
		authinfo += " \"I:#{parameters['authentication']}\"" unless parameters['authentication'].nil?
		authinfo += " \"R:#{parameters['realm']}\"" unless parameters['realm'].nil?
	else
		# Pass through each option untouched
		authinfo += " \"U:#{parameters['username']}\"" unless parameters['username'].nil?
		authinfo += " \"P:#{parameters['password']}\"" unless parameters['password'].nil?
		authinfo += " \"M:#{parameters['mechanisms']}\""
		authinfo += " \"I:#{parameters['authentication']}\"" unless parameters['authentication'].nil?
		authinfo += " \"R:#{parameters['realm']}\"" unless parameters['realm'].nil?
	end
	next if parameters['relay'] != true # Skip this next part if this is not a relay
	port = parameters['port'].nil? ? node['mademedia_sendmail']['relay_port'] : parameters['port']
	relay += "define (\`SMART_HOST', \`#{host}')dnl\n"
	relay += "define (\`RELAY_MAILER_ARGS', \`TCP $h #{port}')dnl\n"
	relay += "define (\`ESMTP_MAILER_ARGS', \`TCP $h #{port}')dnl\n"
end
## Masquerade settings
masquerade = '';
unless node['mademedia_sendmail']['masquerade'].nil?
	masquerade += "FEATURE(always_add_domain)dnl\n"
	masquerade += "FEATURE(\`masquerade_entire_domain')dnl\n"
	masquerade += "FEATURE(\`masquerade_envelope')dnl\n"
	masquerade += "FEATURE(\`allmasquerade')dnl\n"
	node['mademedia_sendmail']['masquerade'].each do |domain|
		masquerade += "MASQUERADE_AS(\`" + domain + "')dnl\n"
		masquerade += "MASQUERADE_DOMAIN(\`" + domain + "')dnl\n"
	end
	masquerade += "MASQUERADE_DOMAIN(localhost)dnl"
	masquerade += "MASQUERADE_DOMAIN(localhost.localhost)dnl"
end
## Additional user configuration
additional = '';
unless node['mademedia_sendmail']['additional'].nil?
	node['mademedia_sendmail']['additional'].each do |additional_line|
		additional += "#{additional_line}dnl\n"
	end
end
## Write configs
template "access_config" do
	path node['mademedia_sendmail'][core_platform]['config_dir'] + "/" + node['mademedia_sendmail']['access_config']
	source "access.erb"
	owner node['mademedia_sendmail']['owner']
	group node['mademedia_sendmail']['group']
	mode  node['mademedia_sendmail']['perms']
	variables({
		:connections => connections,
		:authinfo => authinfo,
	})
end
template "sendmail_config" do
	path node['mademedia_sendmail'][core_platform]['config_dir'] + "/" + node['mademedia_sendmail']['sendmail_config']
	source "sendmail.mc.erb"
	owner node['mademedia_sendmail']['owner']
	group node['mademedia_sendmail']['group']
	mode  node['mademedia_sendmail']['perms']
	variables({
		:relay => relay,
		:mechanisms => node['mademedia_sendmail']['mechanisms'].upcase,
		:listen_address => node['mademedia_sendmail']['listen_address'],
		:local_domain => node['mademedia_sendmail']['local_domain'],
		:config_dir => node['mademedia_sendmail'][core_platform]['config_dir'],
		:masquerade => masquerade,
		:additional => additional,
	})
end

# Install and activate service
bash "Activate configuration files" do
	cwd node['mademedia_sendmail'][core_platform]['config_dir']
	user "root"
	code <<-EOH
		m4 "#{node['mademedia_sendmail']['sendmail_config']}" > "#{node['mademedia_sendmail']['sendmail_compiled_config']}"
		makemap hash "#{node['mademedia_sendmail']['access_config']}" < "#{node['mademedia_sendmail']['access_config']}"
	EOH
end

# (Re)start service after configuration
service node['mademedia_sendmail'][core_platform]['service_name'] do
  supports :status => true, :restart => true, :reload => true
  action :restart
end
