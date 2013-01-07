require 'net/netconf'
require 'net/netconf/jnpr/rpc'

module Netconf::JUNOS
  NETCONF_CLI = "junoscript netconf need-trailer"
  NETCONF_SHELL = "exec xml-mode netconf need-trailer"
end
  
