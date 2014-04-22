require_relative '../domain/diagram'

generator = Diagram.new('1to2')

generator.add_node! Pool, {
    name: 'g1',
    activation: :automatic,
    initial_value: 5,
    mode: :push
}

generator.add_node! Pool, {
    name: 'g2',
    activation: :automatic,
    mode: :push
}

generator.add_node! Pool, {
    name: 'g3'
}

generator.add_edge! Edge, {
    name: 'c1',
    from: 'g1',
    to: 'g2'
}

generator.add_edge! Edge, {
    name: 'c2',
    from: 'g1',
    to: 'g3',
}


generator.add_edge! Edge, {
    name: 'c3',
    from: 'g2',
    to: 'g1',
}

# I want to check the initial state
puts "#### Estado inicial ####"
puts generator

# run and get the end
generator.run!(10,true)

puts "#### Estado final ####"
puts generator
