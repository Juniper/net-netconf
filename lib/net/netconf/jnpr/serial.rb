require 'net/netconf'
require 'net/netconf/serial'
require 'net/netconf/jnpr'

module Netconf
  module TransSerial
    module JUNOS      
      
      def trans_start_netconf( last_console )
        last_console.match(/[^%]\s+$/)
        netconf_cmd = ($1 == '%') ? Netconf::JUNOS::NETCONF_SHELL : Netconf::JUNOS::NETCONF_CLI
        puts netconf_cmd
      end
      
    end      
  end
end
