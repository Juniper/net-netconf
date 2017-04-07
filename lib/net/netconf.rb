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

  def self.waitfor(on_re = nil)
    time_out = @trans_timeout
    wait_io = @trans_waitio

    time_out = nil if time_out == false
    done = false
    rx_buf = ''

    until( rx_buf.match( on_re ) and not IO::select( [@trans], nil, nil, wait_io ) )

      unless IO::select( [@trans], nil, nil, time_out )
        raise TimeoutError, 'Netconf IO timed out while waiting for more data'
      end

      begin

        rx_some = @trans.readpartial( DEFAULT_RDBLKSZ )

        rx_buf += rx_some
        break if rx_buf.match( on_re )

      rescue EOFError # End of file reached
        rx_buf = nil if rx_buf == ''
        break   # out of outer 'until' loop
      end

    end
    rx_buf
  end

  def self.trans_receive
    got = waitfor( Netconf::RPC::MSG_END_RE )
    msg_end = got.rindex( Netconf::RPC::MSG_END )
    got[msg_end .. -1] = ''
    got
  end
end
