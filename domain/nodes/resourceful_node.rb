require 'set'
require_relative '../../domain/resources/token'
require_relative '../../domain/nodes/node'

class ResourcefulNode < Node


  include Invariant

  @is_start = true

  def initialize(hsh=nil)
    @is_start = true
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

  # this method only 'stages' changes; does not commit them (drawing from git terms)
  def stage!

    if  automatic? || is_start?
      trigger_stage!
    end

  end

  def trigger_stage!

    if enabled?
      if push?

        edges
        .shuffle
        .select { |e| e.from?(self) }
        .each {|e| e.carry! }

      elsif pull?

        edges
        .shuffle
        .select {|e| e.to?(self) }
        .each{|e| e.carry! }

      end

    end

  end

  def pull?
    @mode === :pull
  end

  def push?
    @mode === :push
  end

  def automatic?
    @activation === :automatic
  end

  def passive?
    @activation === :passive
  end

  def start?
    @activation === :start
  end

  # this should be at node?
  def typed?
    !untyped?
  end

  def untyped?
    types.empty?
  end

  def resources_added(klass=nil)
    if klass.nil?
      total=0
      @resources_added.each_value { |n| total=total+n }
      total
    else
      @resources_added[klass]
    end
  end

  def resources_removed(klass=nil)
    if klass.nil?
      total=0
      @resources_removed.each_value { |n| total=total+n }
      total
    else
      @resources_removed[klass]
    end
  end

  def is_start?
    if @activation===:start
      answer=@is_start
      @is_start=false
    else
      answer=false
    end
    answer
  end

  def commit!
    super
  end

  def resource_count(type=nil) raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def push_any; raise NotImplementedError,"Please update class #{self.class} to respond to: "; end

  def push_all; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def pull_any; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def pull_all; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def remove_resource!; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def add_resource!; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

end

