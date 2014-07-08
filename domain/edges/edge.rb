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

  # Pinging an Edge means triggering it. It will try and move
  # as many resources (based on its type and those of
  # the two nodes) as it can..
  # @return [Boolean] true in case all required resources
  #  were moved, false otherwise.
  def ping!

    if from.enabled? and to.enabled?

      strategy = ValidTypes.new(to.types, self.types)
      condition = strategy.get_condition

      label.times do

        begin
          res = from.remove_resource_where! &condition
        rescue NoElementsFound
           return false
        end

        to.add_resource!(res)

      end
      true
    else
      false
    end

  end

  # Simulates a ping!, but no resources get actually
  # moved.
  # @return [Boolean] true in case a ping! on this Edge
  #  would return true. False otherwise.
  def test_ping?
    if from.enabled? and to.enabled?

      strategy = ValidTypes.new(to.types, self.types)
      condition = strategy.get_condition

      from.count_re

      label.times do



        begin
          res = from.  remove_resource_where! &condition
        rescue NoElementsFound
          return false
        end

        to.add_resource!(res)

      end
      true
    else
      false
    end
  end

  def supports?(type)
    types.empty? || types.include?(type)
  end

  alias_method :support?, :supports?

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