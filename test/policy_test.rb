require 'test_helper'

class Gandalf::PolicyTest < ActiveSupport::TestCase
  class TestPolicy < Gandalf::Policy
    def can_foo? context = nil
      true
    end

    def can_bar? context = nil
      false
    end
  end

  test "#model returns the given model" do
    model = Object.new
    policy = Gandalf::Policy.new model

    assert_equal model, policy.model
  end

  test "#to_model returns the given model" do
    model = Object.new
    policy = Gandalf::Policy.new model

    assert_equal model, policy.to_model
  end

  test "can? returns false when method isn't defined" do
    policy = TestPolicy.new nil
    refute policy.can? :test, nil
  end

  test "can? returns true when method is defined and returns true" do
    policy = TestPolicy.new nil
    assert policy.can? :foo, nil
  end

  test "can? returns false when method is defined and returns false" do
    policy = TestPolicy.new nil
    refute policy.can? :bar, nil
  end

  test "cannot? returns true when method isn't defined" do
    policy = TestPolicy.new nil
    assert policy.cannot? :test, nil
  end

  test "cannot? returns false when method is defined and returns true" do
    policy = TestPolicy.new nil
    refute policy.cannot? :foo, nil
  end

  test "cannot? returns true when method is defined and returns false" do
    policy = TestPolicy.new nil
    assert policy.cannot? :bar, nil
  end

  test ".can creates a method with the given block" do
    refute TestPolicy.method_defined? :can_test?
    TestPolicy.can(:test) { |context| }
    assert TestPolicy.method_defined? :can_test?
  end

  test ".can creates methods when given an array and block" do
    refute TestPolicy.method_defined? :can_boo?
    refute TestPolicy.method_defined? :can_hoo?
    TestPolicy.can(:boo, :hoo) { |context| }
    assert TestPolicy.method_defined? :can_boo?
    assert TestPolicy.method_defined? :can_hoo?
  end

  test ".can raises an error when no arguments given" do
    assert_raises ArgumentError do
      TestPolicy.can
    end
  end

  test ".can raises an error when no block is given" do
    assert_raises ArgumentError do
      TestPolicy.can :test
    end
  end

  test ".can raises an error when a block which doesn't accept 1 argument is given" do
    assert_raises ArgumentError do
      TestPolicy.can :test, &Proc.new
    end
  end
end