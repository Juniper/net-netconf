require 'net/netconf'

puts "NETCONF v.#{Netconf::VERSION}"

login = {
  target: 'vsrx',
  username: 'jeremy',
  password: 'jeremy1'
}

new_host_name = 'vsrx-abc'

puts "Connecting to device: #{login[:target]}"

Netconf::SSH.new(login) do |dev|
  puts 'Connected!'

  target = 'candidate'

  location = Nokogiri::XML::Builder.new do |x|
    x.configuration do
      x.system do
        x.location do
          x.building 'Main Campus, A'
          x.floor 5
          x.rack 27
        end
      end
    end
  end

  begin
    dev.rpc.lock target

    # --------------------------------------------------------------------
    # configuration as BLOCK

    dev.rpc.edit_config do |x|
      x.configuration do
        x.system do
          x.send(:'host-name', new_host_name)
        end
      end
    end

    # --------------------------------------------------------------------
    # configuration as PARAM

    dev.rpc.edit_config(location)

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
