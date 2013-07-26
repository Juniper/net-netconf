require 'net/ssh'

module Netconf      
  class SSH < Netconf::Transport
    
    NETCONF_PORT = 830
    NETCONF_SUBSYSTEM = 'netconf'    
    
    def initialize( args_h, &block )      
      @args = args_h.clone
      @args[:os_type] = args_h[:os_type] || Netconf::DEFAULT_OS_TYPE
      
      # extend this instance with the capabilities of the specific os_type
      begin
        extend Netconf::const_get( @args[:os_type] )::TransSSH        
      rescue NameError
        # no extensions available ...
      end     
      
      @trans = Hash.new   
      super( &block )
    end
    
    def trans_open( &block )
      # open a connection to the NETCONF subsystem        
      start_args = Hash.new
      start_args[:password] ||= @args[:password]
      start_args[:passphrase] = @args[:passphrase] || nil
      start_args[:port] = @args[:port] || NETCONF_PORT
      start_args.merge!(@args[:ssh_args]) if @args[:ssh_args]
            
      begin
        @trans[:conn] = Net::SSH.start( @args[:target], @args[:username], start_args )     
        @trans[:chan] = @trans[:conn].open_channel{ |ch| ch.subsystem( NETCONF_SUBSYSTEM ) }
      rescue Errno::ECONNREFUSED => e
        if self.respond_to? 'trans_on_connect_refused'
          return trans_on_connect_refused( start_args )
        end
        return nil
      end
      @trans[:chan]
    end
    
    def trans_close     
      @trans[:chan].close if @trans[:chan]
      @trans[:conn].close if @trans[:conn]
    end
        
    def trans_receive
      @trans[:rx_buf] = ''
      @trans[:more] = true
      
      # collect the response data as it comes back ...
      # the "on" functions must be set before calling
      # the #loop method
      
      @trans[:chan].on_data do |ch, data|
        if data.include?( RPC::MSG_END )
          data.slice!( RPC::MSG_END )
          @trans[:rx_buf] << data unless data.empty?
          @trans[:more] = false
        else
          @trans[:rx_buf] << data
        end
      end
      
      # ... if there are errors ... 
      @trans[:chan].on_extended_data do |ch, type, data|
        @trans[:rx_err] = data
        @trans[:more] = false
      end
      
      # the #loop method is what actually performs
      # ssh event processing ...
      
      @trans[:conn].loop { @trans[:more] }        
      
      return @trans[:rx_buf]      
    end
    
    def trans_send( cmd_str )
      @trans[:chan].send_data( cmd_str )  
    end
    
    # accessor to create an Net::SCP object so the caller can perform
    # secure-copy operations (see Net::SCP) for details
    def scp
      @scp ||= Net::SCP.start( @args[:target], @args[:username], :password => @args[:password] )
    end
    
  end # class: SSH
end #module: Netconf

require 'net/netconf/ssh'
