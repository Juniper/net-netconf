require 'net/netconf/jnpr'

puts "NETCONF v.#{Netconf::VERSION}"

login = {
  target: 'vsrx',
  username: 'jeremy',
  password: 'jeremy1'
}

Netconf::SSH.new(login) do |dev|
  configs = dev.rpc.get_configuration do |x|
    x.interfaces(matching: 'interface[name="ge-*"]')
  end

  ge_cfgs = configs.xpath('interfaces/interface')

  puts "There are #{ge_cfgs.count} GE interfaces:"
  ge_cfgs.each do |ifd|
    units = ifd.xpath('unit').count
    puts '   ' + ifd.xpath('name')[0].text + " with #{units} unit" + (units > 1) ? 's' : ''
  end
end
