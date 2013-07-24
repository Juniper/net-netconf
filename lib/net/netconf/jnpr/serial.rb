require 'net/netconf'
require 'net/netconf/serial'
require 'net/netconf/jnpr'

module Netconf
  module Junos    
    module TransSerial      
      def trans_start_netconf( last_console )
        last_console.match(/[^%]\s+$/)
        netconf_cmd = ($1 == '%') ? Netconf::Junos::NETCONF_SHELL : Netconf::Junos::NETCONF_CLI
        puts netconf_cmd
      end      
    end      
  end
end
