module Netconf
  
  class IOProc < Netconf::Transport
    
    DEFAULT_RDBLKSZ = (1024*1024)
    
    attr_reader :args
        
    def initialize( args_h = {}, &block )
      os_type = args_h[:os_type] || Netconf::DEFAULT_OS_TYPE
            
      @args = args_h.clone
      
      # an OS specific implementation must exist to support this transport type
      extend Netconf::const_get( os_type )::IOProc        
      
      @trans_timeout = @args[:timeout] || Netconf::DEFAULT_TIMEOUT
      @trans_waitio = @args[:waitio] || Netconf::DEFAULT_WAITIO

      super( &block )      
    end      
        
    # the OS specific transport must implement this method
    def trans_open # :yield: self      
      raise "Unsupported IOProc"
    end
    
    def trans_receive_hello
      trans_receive()
    end
    
    def trans_send_hello
      nil
    end
    
    def trans_close
      @trans.write Netconf::RPC::MSG_CLOSE_SESSION
      @trans.close
    end
    
    def trans_send( cmd_str )
      @trans.write( cmd_str )
    end
    
    def trans_receive
      got = waitfor( Netconf::RPC::MSG_END_RE )
      msg_end = got.rindex( Netconf::RPC::MSG_END )
      got[msg_end .. -1] = ''
      got
    end
        
    def puts( str = nil )
      @trans.puts( str )
    end
        
    def waitfor( on_re )      
      
      time_out = @trans_timeout
      wait_io = @trans_waitio

      time_out = nil if time_out == false
      done = false
      rx_buf = ''      
                  
      until( rx_buf.match( on_re ) and not IO::select( [@trans], nil, nil, wait_io ) )
              
        unless IO::select( [@trans], nil, nil, time_out )
          raise TimeoutError, "Netconf IO timed out while waiting for more data"
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
    
  end # class: IOProc
end # module: Netconf
