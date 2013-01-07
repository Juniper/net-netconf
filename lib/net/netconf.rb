
require 'nokogiri'

require 'net/netconf/rpc'
require 'net/netconf/exception'         
require 'net/netconf/transport'
require 'net/netconf/ssh'

module Netconf  
  VERSION = "0.2.0"   
  DEFAULT_OS_TYPE = :JUNOS  
  DEFAULT_TIMEOUT = 10
  DEFAULT_WAITIO = 0
end
