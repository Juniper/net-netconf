# frozen_string_literal: true

require 'net/netconf'
require 'net/netconf/jnpr'

module Netconf
  module Junos
    # this is used to handle the case where NETCONF (port 830) is disabled.
    # We can still access the NETCONF subsystem from the CLI using a hidden
    # command 'netconf'
    module TransSSH
      def trans_on_connect_refused(start_args)
        start_args[:port] = 22
        @trans[:conn] = Net::SSH.start(@args[:target], @args[:username], start_args)
        do_once = true
        @trans[:conn].exec(NETCONF_CLI) do |chan, _success|
          @trans[:chan] = chan
          do_once = false
        end
        @trans[:conn].loop { do_once }
        @trans[:chan]
      end
    end
  end
end
