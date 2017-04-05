require 'net/netconf'

puts "NETCONF v.#{Netconf::VERSION}"

login = {
  target: 'vsrx',
  username: 'jeremy',
  password: 'jeremy1'
}

new_host_name = 'vsrx'

puts "Connecting to device: #{login[:target]}"

Netconf::SSH.new(login) do |dev|
  puts 'Connected!'

  target = 'candidate'

  location = Nokogiri::XML::Builder.new do |x|
    x.send(:'configuration-text', <<-EOCONF
    system {
      location {
        building "Main Campus, ABC123"
        floor 5
        rack 27
      }
    }
EOCONF
    )
  end

  begin
    dev.rpc.lock target

    # --------------------------------------------------------------------
    # configuration as BLOCK
    dev.rpc.edit_config(toplevel: 'config-text') do |x|
      x.send(:'configuration-text', <<EOCONF
      system {
        host-name #{new_host_name};
      }
EOCONF
      )
    end
    # --------------------------------------------------------------------
    # configuration as PARAM
    dev.rpc.edit_config(location, toplevel: 'config-text')

    dev.rpc.validate target
    dev.rpc.commit
    dev.rpc.unlock target
  rescue Netconf::LockError
    puts 'Lock error'
  rescue Netconf::EditError
    puts 'Edit error'
  rescue Netconf::ValidateError
    puts 'Validate error'
  rescue Netconf::CommitError
    puts 'Commit error'
  rescue Netconf::RpcError
    puts 'General RPC error'
  else
    puts 'Configuration Committed.'
  end
end
