require 'net/netconf/jnpr'

puts "NETCONF v.#{Netconf::VERSION}"

login = { :target => 'vsrx', :username => "jeremy", :password => "jeremy1" }
  
new_host_name = "vsrx-gizmo"

puts "Connecting to device: #{login[:target]}" 

Netconf::SSH.new( login ){ |dev|
  puts "Connected!"
  
  location = <<EOCONF
system {
   location {
      building "Main Campus, E"
      floor 15
      rack 1117
   }
}
EOCONF
  
  begin
    
    rsp = dev.rpc.lock_configuration

    # --------------------------------------------------------------------    
    # configuration as BLOCK
    
    rsp = dev.rpc.load_configuration( :format => 'text' ) {
      <<-EOCONF
      system {
        host-name #{new_host_name}
      }
EOCONF
    }
    
    # --------------------------------------------------------------------
    # configuration as PARAM
    
    rsp = dev.rpc.load_configuration( location, :format => 'text' )
    
    rpc = dev.rpc.check_configuration
    rpc = dev.rpc.commit_configuration
    rpc = dev.rpc.unlock_configuration
    
  rescue Netconf::LockError => e
    puts "Lock error"
  rescue Netconf::EditError => e
    puts "Edit error"    
  rescue Netconf::ValidateError => e
    puts "Validate error"
  rescue Netconf::CommitError => e
    puts "Commit error"
  rescue Netconf::RpcError => e
    puts "General RPC error"
  else
    puts "Configuration Committed."
  end  
}



