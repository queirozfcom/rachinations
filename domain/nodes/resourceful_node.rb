require 'set'
require_relative '../../domain/resources/token'
require_relative '../../domain/nodes/node'

class ResourcefulNode < Node

  include Invariant



  @is_start = true

  # attr_reader :staged_resources

  # mode= :push, :pull
  # modetype = any, all
  # activation = :automatic, :passive, :start

  # attr_accessor :activation, :mode
  #
  def initialize
    @is_start = true
  end

  def initialize_copy(orig)
    super

    #need to clone the resource bag as well...
    @resources = @resources.clone()

    #don't need this. takes too much space
    @diagram = nil

  end

# this is the execution cycle of a node
# it can be called by diagram or by any node/edge
# however, it can only be called once per turn
# since, two states: :before and :after
# we use 2 states to allow for more states if needed

#
#def run! # should be called by diagram
#  if @state==:before
#    if @activation==:automatic
#    execute!
#    elsif @is_start and @activation == :start
#      execute!
#    else
#      # do nothing for a while
#    end
#  end
#  @state=:after
#end
#
#def commit! # should be called by diagram
#  @state=:before
#  false
#end
#
#def execute! # can be called by any node/thing
#  if @state==:before
#    if push?
#      push(:modetype)
#    elsif pull?
#      pull(:modetype)
#    end
#  end
#  @state=:after
#  @is_start=false
#end

# about my state (every node has a complete set of states)

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

  def is_start?
    if @activation===:start
      answer=@is_start
      @is_start=false
    else
      answer=false
    end
    answer
  end

  def commit!; raise NotImplementedError,"Please update class #{self.class} to respond to: "; end

  def resource_count(type=nil) raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def push_any; raise NotImplementedError,"Please update class #{self.class} to respond to: "; end

  def push_all; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def pull_any; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def pull_all; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def remove_resource!; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  def add_resource!; raise NotImplementedError, "Please update class #{self.class} to respond to: "; end

  #use this lazily?

  private

  def normalize(hsh)
    accepted_options = [:name, :activation, :mode, :types, :initial_value, :diagram]

    #watch out for unknown options - might be typos!
    hsh.each_pair do |key, value|

      if accepted_options.exclude?(key)
        raise ArgumentError.new "Unknown option: in parameter hash: #{key} "
      end

    end
  end

end

