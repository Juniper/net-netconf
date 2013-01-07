require 'net/netconf/jnpr'

puts "NETCONF v.#{Netconf::VERSION}"

login = { :target => 'vsrx', :username => "jeremy", :password => "jeremy1" }
  
new_host_name = "vsrx-jjj"

puts "Connecting to device: #{login[:target]}" 

Netconf::SSH.new( login ){ |dev|
  puts "Connected!"
  
  location = Nokogiri::XML::Builder.new{ |x| 
    x.system {
      x.location {
        x.building "Main Campus, C"
        x.floor 15
        x.rack 37
      }
    }
  }
  
  begin
    
    rsp = dev.rpc.lock_configuration

    # --------------------------------------------------------------------    
    # configuration as BLOCK
    
    rsp = dev.rpc.load_configuration{ |x| 
      x.system {
        x.send(:'host-name', new_host_name )
      }
    }
    
    # --------------------------------------------------------------------
    # configuration as PARAM
    
    rsp = dev.rpc.load_configuration( location )
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
    binding.pry
  else
    puts "Configuration Committed."
  end  
}



