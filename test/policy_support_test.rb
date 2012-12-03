require 'test_helper'

class Gandalf::PolicySupportTest < ActiveSupport::TestCase
  class AssertSupportObject
    include Gandalf::PolicySupport
  end

  class AssertSupportObjectPolicy < Gandalf::Policy
  end

  class RefuteSupportObject
    include Gandalf::PolicySupport
  end

  test "#to_policy should return nil when no policy is found" do
    object = RefuteSupportObject.new
    assert_nil object.to_policy
  end

  test "#to_policy should return the corresponding policy" do
    object = AssertSupportObject.new
    policy = object.to_policy

    refute_nil policy
    assert_kind_of AssertSupportObjectPolicy, policy
    assert_equal object, policy.model
  end
end