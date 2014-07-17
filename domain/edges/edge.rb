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
          res = from.take_resource! &condition
        rescue NoElementsFound
          return false
        end

        to.put_resource!(res,self.freeze)

      end
      true
    else
      false
    end

  end

  # Simulates a ping!, but no resources get actually
  # moved.
  #
  # @param [Boolean] require_all whether to require that the maximum
  #  number of Resources allowed (as per this Edge's label) be
  #  able to pass in order to return true.
  #
  # @return [Boolean] true in case a ping! on this Edge
  #  would return true. False otherwise.
  def test_ping?(require_all=false)
    return false if from.disabled? || to.disabled?

    condition = strategy.get_condition

    available_resources = from.resource_count(&condition)

    if available_resources == 0
      false
    elsif available_resources >= label
      true
    elsif available_resources < label && require_all
      false
    else
      # only some resources are able to pass
      true
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

  def strategy
    ValidTypes.new(self.types,to.types)
  end

  private

  def defaults
    {
        :label => 1,
        :types => []
    }
  end

end