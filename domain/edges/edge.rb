require_relative '../strategies/valid_types'
require_relative '../../domain/exceptions/no_elements_found'

class Edge

  attr_reader :from, :to, :name, :label, :types

  def initialize(hsh)

    @name = hsh.fetch(:name)

    @from = hsh.fetch(:from)

    @to = hsh.fetch(:to)

    #setting default values if needed.
    hsh = defaults.merge hsh

    @label = hsh.fetch(:label)
    @types = hsh.fetch(:types)

  end

  def carry!

    #if both are automatic and one is pushing while the other one is pulling,
    #the two events take place, albeit counter-intuitively.

    #can this be used lazily? this should be tested

    strategy = ValidTypes.new(to.types, self.types)
    condition = strategy.condition

    label.times do

      begin
        res = from.remove_resource_where! &condition
      rescue NoElementsFound
         break
       end

      to.add_resource!(res)

    end

  end

  #alias
  def supports?(type)
    types.empty? || types.include?(type)
  end

  #alias
  def support?(type)
    supports?(type)
  end

  def untyped?
    types.empty?
  end

  def typed?
    not untyped?
  end


  def from?(obj)
    from.equal?(obj)
  end

  def to?(obj)
    to.equal?(obj)
  end

  private

  def defaults
    {
        :label => 1,
        :types => []
    }
  end

end