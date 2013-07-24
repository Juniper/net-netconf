require 'net/telnet'

module Netconf
  
  class Telnet < Netconf::Transport
                
    def initialize( args, trans_args = nil, &block )
      os_type = args[:os_type] || Netconf::DEFAULT_OS_TYPE            
      @args = args.clone
            
      # extend this instance with the capabilities of the specific console
      # type; it needs to define #login and #start_netconf session
      begin
        extend Netconf::const_get( os_type )::TransTelnet        
      rescue NameError
        # no extensions available ...
      end     
      
      my_trans_args = {}
      my_trans_args["Host"] = @args[:target]
      my_trans_args["Port"] = @args[:port] if @args[:port]
      
      @trans = Net::Telnet.new( my_trans_args )
      
      @trans_timeout = @args[:timeout] || Netconf::DEFAULT_TIMEOUT
      @trans_waitio = @args[:waitio] || Netconf::DEFAULT_WAITIO      
     
      super( &block )      
    end      
        
    def trans_open( &block )
      trans_login()
      trans_start_netconf() 
      self
    end
        
    def trans_close
      @trans.write Netconf::RPC::MSG_CLOSE_SESSION
      @trans.close
    end
    
    def trans_send( cmd_str )
      @trans.write( cmd_str )
    end
    
    def trans_receive      
      rsp = @trans.waitfor( Netconf::RPC::MSG_END_RE )
      rsp.chomp!( Netconf::RPC::MSG_END + "\n" )      
    end
    
  end # class: Serial
end # module: Netconf
