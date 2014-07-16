require 'set'
require_relative '../../domain/resources/token'
require_relative '../../domain/nodes/node'

class ResourcefulNode < Node

  include Invariant

  def initialize(hsh=nil)
    @resources_added=Hash.new(0)
    @resources_removed=Hash.new(0)
  end

  def initialize_copy(orig)
    super

    #need to clone the resource bag as well...
    @resources = @resources.clone()

    #don't need this. takes too much space
    @diagram = nil

  end

# pools are about resources

  def supports?(klass)
    if klass.eql?(Token)
      untyped?
    else
      #untyped nodes support everything.
      if untyped?
        true
      else
        typed? && types.include?(klass)
      end
    end
  end

  alias_method :support?, :supports?

  def trigger!
    fire!
  end

  def fire!
    stage!
  end

  def stage!
    # this method only 'stages' changes; does not commit them (drawing from git terms)

    if enabled?
      if push?

        edges
        .shuffle
        .select { |e| e.from?(self) }
        .each { |e| e.ping! }

      elsif pull?

        edges
        .shuffle
        .select { |e| e.to?(self) }
        .each { |e| e.ping! }

      end

    end
  end

  def resources_added(klass=nil)
    if klass.nil?
      @resources_added.values.reduce(0){|acc,elem| acc += elem}
    else
      @resources_added[klass]
    end
  end

  def resources_removed(klass=nil)
    if klass.nil?
      @resources_removed.values.reduce(0){ |acc,elem| acc += elem }
    else
      @resources_removed[klass]
    end
  end

  def commit!
    super
  end

  def unlock_resources!
    @resources.each_where { |r|
      if r.locked?
        r.unlock!
      end
    }
  end

  def resource_count(type=nil)
    raise NotImplementedError, "Please update class #{self.class} to respond to: ";
  end

  def push_any;
    raise NotImplementedError, "Please update class #{self.class} to respond to: ";
  end

  def push_all;
    raise NotImplementedError, "Please update class #{self.class} to respond to: ";
  end

  def pull_any;
    raise NotImplementedError, "Please update class #{self.class} to respond to: ";
  end

  def pull_all;
    raise NotImplementedError, "Please update class #{self.class} to respond to: ";
  end

  def remove_resource!;
    raise NotImplementedError, "Please update class #{self.class} to respond to: ";
  end

  def put_resource!;
    raise NotImplementedError, "Please update class #{self.class} to respond to: ";
  end

end

