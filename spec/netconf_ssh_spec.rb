require 'net/netconf'

RSpec.describe Netconf::SSH do
  let(:session) { Netconf::SSH.new(target: 'host') }

  it 'not logged in' do
    expect(session.closed?).to eq(true)
  end
end
