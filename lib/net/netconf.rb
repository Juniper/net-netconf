# frozen_string_literal: true

require 'nokogiri'
require 'net/netconf/version'
require 'net/netconf/rpc'
require 'net/netconf/exception'
require 'net/netconf/transport'
require 'net/netconf/ssh'

# base Netconf constants and methods
module Netconf
  NAMESPACE = 'urn:ietf:params:xml:ns:netconf:base:1.0'
  DEFAULT_OS_TYPE = :Junos
  DEFAULT_TIMEOUT = 10
  DEFAULT_WAITIO = 0

  # do not raise RpcError exception when rpc returns a warning
  @raise_on_warning = false

  def self.raise_on_warning=(bool)
    @raise_on_warning = bool
  end

  def self.raise_on_warning
    @raise_on_warning
  end
end
