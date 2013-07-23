require 'net/netconf'

puts "NETCONF v.#{Netconf::VERSION}"

login = { :target => 'vsrx', :username => "jeremy", :password => "jeremy1" }
  
new_host_name = "vsrx"

puts "Connecting to device: #{login[:target]}" 

Netconf::SSH.new( login ){ |dev|
  puts "Connected!"
  
  target = 'candidate'
  
  location = Nokogiri::XML::Builder.new{ |x| x.send(:'configuration-text', <<-EOCONF
    system {
      location {
        building "Main Campus, ABC123"
        floor 5
        rack 27
      }
    }
EOCONF
  )}
  
  
  begin
    
    rsp = dev.rpc.lock target

    # --------------------------------------------------------------------    
    # configuration as BLOCK
    
    rsp = dev.rpc.edit_config(:toplevel => 'config-text'){ 
      |x| x.send(:'configuration-text', <<EOCONF
      system {
        host-name #{new_host_name};
      }
EOCONF
    )}
    
    # --------------------------------------------------------------------
    # configuration as PARAM
    
    rsp = dev.rpc.edit_config( location, :toplevel => 'config-text' )
    
    rsp = dev.rpc.validate target
    rpc = dev.rpc.commit
    rpc = dev.rpc.unlock target
    
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



