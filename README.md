# Netconf
[![Gem Version](https://badge.fury.io/rb/netconf.svg)](https://badge.fury.io/rb/netconf)
[![Dependency Status](https://gemnasium.com/badges/github.com/Juniper/net-netconf.svg)](https://gemnasium.com/github.com/Juniper/net-netconf)
[![Build Status](https://travis-ci.org/Juniper/net-netconf.svg?branch=master)](https://travis-ci.org/Juniper/net-netconf)
[![Code Climate](https://codeclimate.com/github/Juniper/net-netconf/badges/gpa.svg)](https://codeclimate.com/github/Juniper/net-netconf)
[![Test Coverage](https://codeclimate.com/github/Juniper/net-netconf/badges/coverage.svg)](https://codeclimate.com/github/Juniper/net-netconf/coverage)

## Description
Device management using the NETCONF protocol as specified in
[RFC4741](http://tools.ietf.org/html/rfc4741) and
[RFC6241](http://tools.ietf.org/html/rfc6241).

## Features
* Extensible protocol transport framework for SSH and non-SSH
  * SSH transport using [Net::SSH](http://net-ssh.rubyforge.org)
  * Telnet transport using Net::Telnet (Ruby Library)
  * Serial transport using [Ruby/SerialPort](http://ruby-serialport.rubyforge.org/)

* NETCONF Standard RPCs
  * get-config, edit-config
  * lock, unlock
  * validate, discard-changes

* Flexible RPC mechanism
  * Netconf::RPC::Builder to metaprogram RPCs
  * Vendor extension framework for custom RPCs

* XML processing using [Nokogiri](http://nokogiri.org)

## Synopsis

```ruby
require 'net/netconf'

# create the options hash for the new NETCONF session. If you are
# using ssh-agent, then omit the :password

login = { target: 'vsrx', username: 'root', password: 'Amnesiac' }

# provide a block and the session will open, execute, and close

Netconf::SSH.new( login ){ |dev|

  # perform the RPC command:
  # <rpc>
  #    <get-chassis-inventory/>
  # </rpc>

  inv = dev.rpc.get_chassis_inventory

  # The response is in Nokogiri XML format for easy processing ...

  puts 'Chassis: ' + inv.xpath('chassis/description').text
  puts 'Chassis Serial-Number: ' + inv.xpath('chassis/serial-number').text
}
```

Alternative explicity open, execute RPCs, and close

```ruby
require 'net/netconf'

login = { target: 'vsrx', username: 'root', password: 'Amnesiac' }

dev = Netconf::SSH.new(login)
dev.open

inv = dev.rpc.get_chassis_inventory

puts 'Chassis: ' + inv.xpath('chassis/description').text
puts 'Chassis Serial-Number: ' + inv.xpath('chassis/serial-number').text

dev.close
```

## Using Netconf
### Remote Procedure Calls (RPCs)
Each Netconf session provides a readable instance variable - __rpc__. This is used to execute Remote Procedure Calls (RPCs). The @rpc will include the NETCONF standard RPCs, any vendor specific extension, as well as the ability to metaprogram new onces via method_missing.

Here are some examples to illustrate the metaprogamming:

Without any parameters, the RPC is created by swapping underscores (_) to
hyphens (-):

```ruby
require 'net/netconf'

dev.rpc.get_chassis_inventory

# <rpc>
#    <get-chassis-inventory/>
# </rpc>
```

You can optionally provide RPC parameters as a hash:

```ruby
dev.rpc.get_interface_information(interface_name: 'ge-0/0/0', terse: true )

# <rpc>
#    <get-interface-information>
#       <interface-name>ge-0/0/0</interface-name>
#       <terse/>
#   </get-interface-information>
# </rpc>
```

You can additionally supply attributes that get assigned to the toplevel
element. In this case You must enclose the parameters hash to disambiquate it
from the attributes hash, or declare  a variable for the parameters hash.

```ruby
dev.rpc.get_interface_information({interface_name: 'ge-0/0/0', terse: true }, { format: 'text'})

# <rpc>
#    <get-interface-information format='text'>
#       <interface-name>ge-0/0/0</interface-name>
#       <terse/>
#   </get-interface-information>
# </rpc>
```

If you want to provide attributes, but no parameters, then:

```ruby
dev.rpc.get_chassis_inventory(nil, format: 'text')

# <rpc>
#    <get-chassis-inventory format='text'/>
# </rpc>
```

### Retrieving Configuration
To retrieve configuration from a device, use the `get-config` RPC. Here is
an example, but you can find others in the __examples__ directory:

```ruby
require 'net/netconf'

login = { target: 'vsrx', username: 'root', password: 'Amnesia' }

puts "Connecting to device: #{login[:target]}"

Netconf::SSH.new(login) do |dev|
  puts 'Connected.'

  # ----------------------------------------------------------------------
  # retrieve the full config.  Default source is 'running'
  # Alternatively you can pass the source name as a string parameter
  # to #get_config

  puts 'Retrieving full config, please wait ... '
  cfgall = dev.rpc.get_config
  puts "Showing 'system' hierarchy ..."
  puts cfgall.xpath('configuration/system')     # JUNOS toplevel config element is <configuration>

  # ----------------------------------------------------------------------
  # specifying a filter as a block to get_config

  cfgsvc1 = dev.rpc.get_config do |x|
   x.configuration { x.system { x.services } }
  end

  puts 'Retrieved services as BLOCK:'
  cfgsvc1.xpath('//services/*').each { |s| puts s.name }

  # ----------------------------------------------------------------------
  # specifying a filter as a parameter to get_config

  filter = Nokogiri::XML::Builder.new do |x|
   x.configuration { x.system { x.services } }
  end

  cfgsvc2 = dev.rpc.get_config(filter)
  puts 'Retrieved services as PARAM:'
  cfgsvc2.xpath('//services/*').each { |s| puts s.name }

  cfgsvc3 = dev.rpc.get_config(filter)
  puts 'Retrieved services as PARAM, re-used filter'
  cfgsvc3.xpath('//services/*').each { |s| puts s.name }
end
```

__NOTE__: There is a JUNOS RPC, `get-configuration`, that provides Juniper
specific extensions as well.

### Changing Configuration
To retrieve configuration from a device, use the `edit-config` RPC. Here is
an example, but you can find others in the __examples__ directory:

```ruby
require 'net/netconf'

login = { target: 'vsrx', username: 'root', password: 'Amnesia' }

new_host_name = 'vsrx-abc'

puts "Connecting to device: #{login[:target]}"

Netconf::SSH.new(login) do |dev|
  puts 'Connected!'

  target = 'candidate'

  # JUNOS toplevel element is 'configuration'

  location = Nokogiri::XML::Builder.new do |x|
    x.configuration {
      x.system {
        x.location {
          x.building 'Main Campus, A'
          x.floor 5
          x.rack 27
        }
      }
    }
  end

  begin
    rsp = dev.rpc.lock target

    # --------------------------------------------------------------------
    # configuration as BLOCK

    rsp = dev.rpc.edit_config do |x|
      x.configuration {
        x.system {
          x.send(:'host-name', new_host_name )
        }
      }
    end

    # --------------------------------------------------------------------
    # configuration as PARAM

    rsp = dev.rpc.edit_config(location)

    rsp = dev.rpc.validate target
    rpc = dev.rpc.commit
    rpc = dev.rpc.unlock target

  rescue Netconf::LockError => e
    puts 'Lock error'
  rescue Netconf::EditError => e
    puts 'Edit error'
  rescue Netconf::ValidateError => e
    puts 'Validate error'
  rescue Netconf::CommitError => e
    puts 'Commit error'
  rescue Netconf::RpcError => e
    puts 'General RPC error'
  else
    puts 'Configuration Committed.'
  end
end
```

__NOTE__: There is a JUNOS RPC, `load-configuration`, that provides
Juniper specific extensions as well.

## Authors and Contributors
* [Jeremy Schulman](www.linkedin.com/in/jeremyschulman), Juniper Networks
* [Ankit Jain](http://www.linkedin.com/in/ankitj093), Juniper Networks
* [Kevin Kirsche](mailto:Kev.Kirsche+GitHub@gmail.com)
* [David Gethings](https://www.linkedin.com/in/david-gethings-59a2051/), Juniper Networks
