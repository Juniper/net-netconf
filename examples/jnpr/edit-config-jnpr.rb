require 'net/netconf/jnpr'

puts "NETCONF v#{Netconf::VERSION}"

login = { :target => 'ex4', :username => "jeremy", :password => "jeremy1" }
  
new_host_name = "ex4-abc"

puts "Connecting to device: #{login[:target]}" 

Netconf::SSH.new( login ){ |dev|
  puts "Connected!"
  
  # when providing a collection of configuration,
  # you need to include the <configuration> as the 
  # toplevel element
  
  location = Nokogiri::XML::Builder.new{ |x| 
    x.configuration {
      x.system {
        x.location {
          x.building "Main Campus, D"
          x.floor 22
          x.rack 38
        }
      }
      x.system {
        x.services {
          x.ftp;
        }
      }
    }
  }
  
  begin
    
    rsp = dev.rpc.lock_configuration
    
    # --------------------------------------------------------------------
    # configuration as PARAM
    
    rsp = dev.rpc.load_configuration( location,  :action => 'replace' )
    
    # --------------------------------------------------------------------    
    # configuration as BLOCK
    
    rsp = dev.rpc.load_configuration{ |x| 
      x.system {
        x.send(:'host-name', new_host_name )
      }
    }
    
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



