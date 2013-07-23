require 'net/netconf'
require 'net/netconf/jnpr/rpc'
require 'net/netconf/jnpr/junos_config'

module Netconf::Junos
  NETCONF_CLI = "junoscript netconf need-trailer"
  NETCONF_SHELL = "exec xml-mode netconf need-trailer"
end
  
