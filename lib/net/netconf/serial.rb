require 'serialport'

module Netconf
  
  class Serial < Netconf::Transport
    
    DEFAULT_BAUD = 9600
    DEFAULT_DATABITS = 8
    DEFAULT_STOPBITS = 1
    DEFAULT_PARITY = SerialPort::NONE
    DEFAULT_RDBLKSZ = (1024*1024)
    
    attr_reader :args
        
    def initialize( args_h, &block )
      os_type = args_h[:os_type] || Netconf::DEFAULT_OS_TYPE
      
      raise Netconf::InitError, "Missing 'port' param" unless args_h[:port]
      raise Netconf::InitError, "Missing 'username' param" unless args_h[:username]
      
      @args = args_h.clone
      @args[:prompt] ||= /([%>])\s+$/
        
      # extend this instance with the capabilities of the specific console
      # type; it needs to define #trans_start_netconf session
      # this must be provided! if the caller does not, this will 
      # throw a NameError exception.
      
      extend Netconf::const_get( os_type )::TransSerial        
      
      @trans_timeout = @args[:timeout] || Netconf::DEFAULT_TIMEOUT
      @trans_waitio = @args[:waitio] || Netconf::DEFAULT_WAITIO

      super( &block )      
    end      
    
    def login
      
      begin
        puts
        waitfor(/ogin:/)
      rescue Timeout::Error
        puts
        waitfor(/ogin:/)
      end
      
      puts @args[:username]
      
      waitfor(/assword:/)
      puts @args[:password]
      
      waitfor( @args[:prompt] )
    end
    
    def trans_open # :yield: self
      
      baud = @args[:speed] || DEFAULT_BAUD
      data_bits = @args[:bits] || DEFAULT_DATABITS
      stop_bits = @args[:stop] || DEFAULT_STOPBITS
      parity = @args[:parity] || DEFAULT_PARITY
      
      @trans = SerialPort.new( @args[:port], baud, data_bits, stop_bits, parity )            
            
      got = login()      
      yield self if block_given?      
      trans_start_netconf( got )      
      
      self
    end
    
    def trans_receive_hello
      hello_str = trans_receive()
      so_xml = hello_str.index("\n") + 1
      hello_str.slice!(0, so_xml)
      hello_str
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
      @trans.puts str 
    end
        
    def waitfor( this_re = nil )      
      on_re = this_re || @args[:prompt]
      
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
    
  end # class: Serial
end # module: Netconf
