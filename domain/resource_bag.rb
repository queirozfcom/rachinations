require 'active_support/all'
require_relative '../domain/modules/common/invariant'


class ResourceBag
  include Invariant

  def initialize
    @store = Array.new
  end

  def initialize_copy(orig)
    super
    @store=@store.map { |el| el.clone }

  end

  def add!(obj)
    @store.push(obj)
  end

  #retrieve
  def get(klass)

    if count(klass) === 0
      raise NoElementsOfGivenTypeError, "No elements of class #{klass} found."
    end

    obj = store.select { |el| el.is_a?(klass) }.sample

    remove_element!(obj)
    obj

  end

  def count(klass)

    inv { klass.is_a?(Class) }

    store.select { |el| el.is_a?(klass) }.length

  end

  def count_where(&blk)

    raise ArgumentError, 'Please supply a block containing the condition.' unless block_given?

    amount = 0

    store.each { |e|
      amount += 1 if yield e
    }

    amount

  end

  def each_where
    raise ArgumentError, 'Please supply a block containing the condition to apply for each resource.' unless block_given?

    store.each { |r| yield r }

  end

  def get_where &condition
    raise ArgumentError, 'Please supply a block containing the condition to apply..' unless block_given?
    raise NoElementsMatchingConditionError, "No elements found matching given condition." unless theres_at_least_one_where &condition

    obj = store.select{|r| r.unlocked? }.select { |r| (yield r) }.sample

    remove_element!(obj)
    obj

  end

  # created so that I don't have to call count everytime just to see whether there's at least one element matching said condition
  def theres_at_least_one_where

    raise ArgumentError, 'Please supply a block containing the condition.' unless block_given?

    store.each do |e|
      if e.unlocked? && (yield e)
        return true
      end
    end

    false

  end

  def to_s
    out = ''

    classes = store.map { |el| el.class }.uniq

    classes.each do |klass|

      name = if klass.name.nil?
               'Anonymous Klass'
             else
               klass.name
             end

      out += "\n"+'    '+ name + ' -> '+ count(klass).to_s+"\n\n"
    end

    if classes.empty?
      "\n    Empty\n\n"
    else
      out
    end


  end

  private


  def store
    @store
  end

  def remove_element!(obj)

    if @store.delete(obj).nil?
      raise NoElementsOfGivenTypeError
    end

  end

end