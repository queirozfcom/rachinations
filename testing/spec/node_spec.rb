require_relative 'spec_helper'

describe Node do

  it 'knows which edges are incoming' do

    n = Node.new

    e = double(:to => n)

    n.attach_edge(e)

    expect(n.edges).to include e
    expect(n.incoming_edges).to include e

  end

  it 'knows which edges are outgoing' do

    n = Node.new

    e = double(:from => n)

    n.attach_edge(e)

    expect(n.edges).to include e
    expect(n.outgoing_edges).to include e

  end

end