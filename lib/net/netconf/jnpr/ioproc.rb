require 'net/netconf'
require 'net/netconf/ioproc'
require 'net/netconf/jnpr'

module Netconf
  module Junos
    module IOProc
      def trans_open   
        @trans = IO.popen( "xml-mode netconf need-trailer", "r+")                             
        self
      end
    end
  end
end
