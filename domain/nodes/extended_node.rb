require 'set'
require_relative '../resources/token'
require_relative '../resource_bag'

class ExtendedNode < Node

  include Invariant

  # mode= :push, :pull
  # modetype = any, all
  # activation = :automatic, :passive, :start

  attr_accessor  :activation, :mode , :modetype, :state

  @is_start=true # must check this in Ruby, I want a instance variable initialized to true
  @state=:before # it is a 2 state machine - before and after. It should run some things only at :before

# this is the execution cycle of a node
# it can be called by diagram or by any node/edge
# however, it can only be called once per turn
# since, two states: :before and :after
# we use 2 states to allow for more states if needed


  def run! # should be called by diagram
    if @state==:before
      if @activation==:automatic
      execute!
      elsif @is_start and @activation == :start
        execute!
      else
        # do nothing for a while
      end
    end
    @state=:after
  end

  def commit! # should be called by diagram
    @state=:before
    false
  end

  def execute! # can be called by any node/thing
    if @state==:before
      if push?
        push(:modetype)
      elsif pull?
        pull(:modetype)
      end
    end
    @state=:after
    @is_start=false
  end

  # about my state (every node has a complete set of states)

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

  def all?
    @modetype === :all
  end

  def any?
    @modetype === :any
  end

  private

  def push
    if any?
      pushany
    elsif all?
      pushall
    end
  end

  def pull
    if any?
      pullany
    elsif all?
      pullall
    end
  end

  def normalize(hsh)
    accepted_options = [:name, :activation, :mode, :modetype, :types, :initial_value, :diagram]

    #watch out for unknown options - might be typos!
    hsh.each_pair do |key, value|

      if accepted_options.exclude?(key)
        raise ArgumentError.new "Unknown option: in parameter hash: #{key} "
      end

    end
  end

end

