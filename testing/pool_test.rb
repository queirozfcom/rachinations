require_relative '../domain/diagram'
require "rubygems"
gem 'minitest'
require "minitest/autorun"
require 'coveralls'
Coveralls.wear!

class PoolTest < MiniTest::Test

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_create_simple_Pool_sending_all_parameters

    pool = Pool.new name: 'pool0', :activation => :automatic, :mode => :push, :initial_value => 78

    assert_equal 78, pool.resource_count
    assert_equal 'pool0', pool.name
    assert pool.automatic?
    assert pool.push?
    assert pool.untyped?

  end

  def test_create_simple_pool_default_attributes

    pool = Pool.new name: 'pool1'

    assert_equal 0, pool.resource_count
    assert_equal 'pool1', pool.name
    assert pool.passive?
    assert pool.pull?
    assert pool.untyped?
  end

  def test_create_one_custom_type_no_initial_values
    mYCLASS = Class.new(Token)

    pool = Pool.new name: 'pool1', types: [mYCLASS]

    assert_equal 0, pool.resource_count(mYCLASS)
    assert_equal 'pool1', pool.name
    assert pool.passive?
    assert pool.pull?
    assert pool.typed?
    assert pool.supports? mYCLASS

  end

  def test_create_one_custom_type_implicitly_via_initial_values

    kLASS = Class.new(Token)

    pool = Pool.new name: 'pool1', initial_value: {kLASS => 50}, mode: :push

    assert_equal 50, pool.resource_count(kLASS)
    assert_equal 'pool1', pool.name
    assert pool.passive?
    assert pool.push?
    assert pool.supports? kLASS
    assert pool.typed?

    assert_raises(ArgumentError) { pool.resource_count }
    assert_raises(ArgumentError) { pool.resource_count(Hash) }

  end

  def test_create_two_custom_types_no_initial_values

    vERDE = Class.new(Token)
    aMARELO = Class.new(Token)
    aZUL = Class.new(Token)

    pool = Pool.new name: 'pool1', types: [vERDE, aMARELO], activation: :automatic

    assert_equal 'pool1', pool.name
    assert pool.supports? vERDE
    assert pool.supports? aMARELO
    assert_equal 0, pool.resource_count(vERDE)
    assert_equal 0, pool.resource_count(aMARELO)
    assert pool.typed?
    assert pool.automatic?

    assert_raises(ArgumentError) { pool.resource_count(aZUL) }
    assert_raises(ArgumentError) { pool.resource_count }

  end

  def test_create_two_custom_types_implicitly_via_initial_value

    fOOTBALL = Class.new(Token)
    pERSON = Class.new(Token)

    pool = Pool.new name: 'pool1', initial_value: {fOOTBALL => 10, pERSON => 40}

    assert pool.supports? fOOTBALL
    assert pool.supports? pERSON

    assert_equal 10, pool.resource_count(fOOTBALL)
    assert_equal 40, pool.resource_count(pERSON)

    assert pool.typed?

    err=assert_raises(ArgumentError) { pool.resource_count(Object) }
    assert_match /unsupported/i, err.message

    err=assert_raises(ArgumentError) { pool.resource_count }
    assert_match /typed/i, err.message
  end

  def test_each_resource_is_unique
    #if a source generates 4 Footballs, then the Footballs that will end up in the other nodes are not
    #just *any* Footballs, but the same Footballs, as identified by their object_id.

    football = Class.new(Token)

    n1 = Pool.new name:'n1',initial_value: {football=>1}

    n2 = Pool.new name:'n1', types: [football]

    tk = n1.remove_resource!(football)

    obj_id_1 = tk.object_id

    n2.add_resource!(tk)

    obj_id_2 = n2.remove_resource!(football).object_id

    assert obj_id_1===obj_id_2

  end

end