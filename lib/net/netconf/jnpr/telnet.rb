require 'net/netconf'
require 'net/netconf/telnet'
require 'net/netconf/jnpr'

module Netconf
  module TransTelnet
    module JUNOS
      
      def trans_login
        l_rsp = @trans.login( @args[:username], @args[:password] )
        # @@@/JLS: need to rescue the timeout ... ???      
        l_rsp.match("([>%])\s+$")
        @exec_netconf = ($1 == '%') ? Netconf::JUNOS::NETCONF_SHELL : Netconf::JUNOS::NETCONF_CLI
      end
      
      def trans_start_netconf
        @trans.puts @exec_netconf
      end
      
    end
  end  
end    

