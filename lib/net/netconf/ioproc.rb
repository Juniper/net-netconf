# frozen_string_literal: true

module Netconf
  class IOProc < Netconf::Transport
    DEFAULT_RDBLKSZ = (1024 * 1024)

    attr_reader :args

    def initialize(args_h = {}, &block)
      os_type = args_h[:os_type] || Netconf::DEFAULT_OS_TYPE

      @args = args_h.clone

      # an OS specific implementation must exist to support this transport type
      extend Netconf::const_get(os_type)::IOProc

      @trans_timeout = @args[:timeout] || Netconf::DEFAULT_TIMEOUT
      @trans_waitio = @args[:waitio] || Netconf::DEFAULT_WAITIO

      super(&block)
    end

    # the OS specific transport must implement this method
    def trans_open # :yield: self
      raise 'Unsupported IOProc'
    end

    def trans_receive_hello
      trans_receive
    end

    def trans_send_hello
      nil
    end

    def trans_close
      @trans.write Netconf::RPC::MSG_CLOSE_SESSION
      @trans.close
    end

    def trans_send(cmd_str)
      @trans.write(cmd_str)
    end

    def trans_receive
      Netconf.trans_receive
    end

    def puts(str = nil)
      @trans.puts(str)
    end

    def waitfor(on_re)
      Netconf.waitfor(on_re)
    end
  end # class: IOProc
end # module: Netconf
