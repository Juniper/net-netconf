
require 'nokogiri'

require 'net/netconf/version'
require 'net/netconf/rpc'
require 'net/netconf/exception'         
require 'net/netconf/transport'
require 'net/netconf/ssh'

module Netconf  
  NAMESPACE = "urn:ietf:params:xml:ns:netconf:base:1.0"  
  DEFAULT_OS_TYPE = :Junos  
  DEFAULT_TIMEOUT = 10
  DEFAULT_WAITIO = 0
  
  @raise_on_warning = false          # rpc-error with <error-severity> = 'warning' will not raise RpcError excption
  
  def self.raise_on_warning=( bool )
    @raise_on_warning = bool
  end
  def self.raise_on_warning
    @raise_on_warning
  end

end
