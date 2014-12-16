mademedia_sendmail
========
A basic sendmail cookbook for Chef, offering the following configuration options;

- Smart hosts / SMTP relays
- Masquerading
- Different authentication mechanisms
- Listen address and local domain
- User, group and permissions of configuration files

Additionally it supports the following features;

- Automatic Base-64 encoding of credentials for LOGIN authentication mechanism
- Support for multiple access_db entries including realm and identification where required
- User-specified sendmail configuraiton options with automatic "dnl" terminator


Requirements
------------
### Platforms
Although this cookbook has only been tested on Amazon Linux (in particular with Opsworks), it *should* support the following platforms;

- Debian and derivaties (Ubuntu etc)
- Red Hat and derivatives (Amazon Linux, CentOS, Fedora, Scientific Linux etc)

### Cookbooks
There is no specific dependency on another cookbook, however it may require either the apt or yum cookbook depending on implementation.

Attributes
----------
Although the best place to see what attributes are available is to check the **attributes/default.rb** file in the source code, here are the common ones with defaults in (parenthesis) and variable types in [brackets];

### Service-wide configuration options
- `node['mademedia_sendmail']['listen_address']` - The IP address to listen on (127.0.0.1) [string]
- `node['mademedia_sendmail']['local_domain']` - The local domain that sendmail uses (localhost.localdomain) [string]
- `node['mademedia_sendmail']['relay_port']` - The default port used for relaying to smart hosts / SMTP relay, this can be overriden in each authinfo block as per below (587) [string]
- `node['mademedia_sendmail']['mechanisms']` - Authentication mechanisms supported when using smart hosts / SMTP relays (EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN) [string]
- `node['mademedia_sendmail']['masquerade']` - A list of domains for masquerading () [array of strings]
- `node['mademedia_sendmail']['additional']` - A list of user-defined lines to append near the end of sendmail.mc, these will automatically be sufficed with "dnl" () [array of strings]

### Mail origin options
- `node['mademedia_sendmail']['connections']` - A list of valid origins of email (see below) [hash]

The `node['mademedia_sendmail']['connections']` attribute default is as follows, you are welcome to append or overwrite this however it's highly recommend you leave in the default options to permit local mail relay;

```ruby
node['mademedia_sendmail']['connections'] = {
	'localhost.localdomain' => 'relay',
	'localhost' => 'relay',
	'127.0.0.1' => 'relay',
}
```

### Authentication and smart host configuration options
- `node['mademedia_sendmail']['authinfo']` - A list of authentication settings and relay hosts () [hash]

The `node['mademedia_sendmail']['authinfo']` attribute by default is empty and you'll need to fill it in. The format comprises as the following;

```ruby
node['mademedia_sendmail']['authinfo'] = {
	'hostname' => {
		'username' => 'marco@polo.com',
		'password' => 'venice',
		'mechanisms' => 'plain',
		'authentication' => NULL,
		'realm' => NULL,
		'relay' => true,
		'port' => NULL
	}
}
```

Each entry will add an item to access_db, and if you tag it as a relay, it will also be added to sendmail.mc as a smart host. Although you can specify multiple hostnames but **only one can be tagged as a relay** (otherwise it may break sendmail, this is untested).

The following options are available to you;

- `hostname` - The hostname of the access_db entry / smart host / SMTP relay - required () [string]
- `username` - The username for the access_db entry / smart host / SMTP relay - required () [string]
- `password` - The password for the access_db entry / smart host / SMTP relay - required () [string]
- `mechanisms` - Authentication mechanisms for the access_db entry / smart host / SMTP relay - required () [string]
- `authentication` - Authentication identity for the access_db entry / smart host / SMTP relay - optional () [string]
- `realm` - Authentication realm for the access_db entry / smart host / SMTP relay - optional () [string]
- `relay` - Flag this entry as the smart host / SMTP relay - required for smart host / SMTP relay (false) [boolean]
- `port` - Port to connect to on the smart host / SMTP relay - optional (`node['mademedia_sendmail']['relay_port']`) [string]

Usage
-----
Using this cookbook is simple and can be completed in three easy steps;

1. Include the mademedia_sendmail attribute file in yours with `include_attribute "mademedia_sendmail::default"`
2. Configure your settings as per the attributes section
3. Include the mademedia_sendmail cookbook in your chef run either directly or in your recipe with `include_recipe "mademedia_sendmail::default"`

Naturally there are other ways to configure the settings. One popular way when using Amazon Opsworks is to use the *Custom JSON* feature of every Opsworks stack to pass in the configuration settings (and safer than storing credentials in version control), here's an example of some JSON to set up a smart relay host;

```json
{
    "mademedia_sendmail": {
        "authinfo": {
            "mail.foo.com": {
                "mechanisms": "LOGIN",
                "username": "relayuser@foo.com",
                "password": "marcopolo",
                "port": "587",
                "relay": true
            }
        }
    }
}
```

Additional Information
-----------
### Maintainers
Jason Gaunt (<jason.gaunt@mademedia.co.uk>)

### License
```text
The MIT License (MIT)

Copyright (c) 2014 Made Media Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
