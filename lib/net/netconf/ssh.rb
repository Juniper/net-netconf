require 'net/ssh'

module Netconf      
  class SSH < Netconf::Transport
    
    NETCONF_PORT = 830
    NETCONF_SUBSYSTEM = 'netconf'    
    
    def initialize( args_h, &block )      
      @args = args_h.clone
      @trans = Hash.new   
      
      super( &block )
    end
    
    # This opens the underlying Net::SSH transport object.
    # Options that are valid to Net::SSH#start can be passed here in the
    # +start_args+ option hash.  Some Net::SSH#start documentation can be found
    # here:
    # http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
    #
    # Example of jumping SSHing through an intermediary host:
    #
    #   jump_host = Net::SSH::Proxy::Command.new('ssh admin_host.ops.colo.example.com nc %h %p')
    #   netconf = Netconf::SSH.new(:target => 'fxp0.firewall1.colo.example.com', :username => 'root', :port => 22)
    #   netconf.trans_open(:proxy => jump_host)
    #   netconf.open
    #   netconf.rpc.get_chassis_inventory
    #   ......
    def trans_open( start_args = {}, &block )
      # open a connection to the NETCONF subsystem
      start_args[:password] ||= @args[:password]
      start_args[:passphrase] = @args[:passphrase] || nil
      start_args[:port] = @args[:port] || NETCONF_PORT
      
      @trans[:conn] = Net::SSH.start( @args[:target], @args[:username], start_args )     
      @trans[:chan] = @trans[:conn].open_channel{ |ch| ch.subsystem( NETCONF_SUBSYSTEM ) }      
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
