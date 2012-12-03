require 'test_helper'

class GandalfTest < ActionController::TestCase
  class SignedInRedirect < Exception; end
  class SignedOutRedirect < Exception; end

  class GandalfController < ActionController::Base
    include Gandalf

    attr_accessor :user

    gandalf_retrieve_user :user
    gandalf_persist_user :user=
  end

  tests GandalfController

  test ".gandalf_retrieve_user should return the current value when no arguments are passed" do
    assert_equal :user, @controller.class.gandalf_retrieve_user
  end

  test ".gandalf_retrieve_user should raise an error when a block is given with an arity above 1" do
    assert_raises ArgumentError do
      @controller.class.gandalf_retrieve_user{|one, two|}
    end
  end

  test ".gandalf_retrieve_user should raise an error when a block is given with an arity is zero" do
    assert_raises ArgumentError do
      @controller.class.gandalf_retrieve_user{||}
    end
  end

  test ".gandalf_persist_user should return the current value when no arguments are passed" do
    assert_equal :user=, @controller.class.gandalf_persist_user
  end

  test ".gandalf_persist_user should raise an error when a block is given with an arity above 2" do
    assert_raises ArgumentError do
      @controller.class.gandalf_persist_user{|one, two, three|}
    end
  end

  test ".gandalf_persist_user should raise an error when a block is given with an arity is zero" do
    assert_raises ArgumentError do
      @controller.class.gandalf_persist_user{||}
    end
  end

  test "#current_user should return the user" do
    user = Object.new
    @controller.user = user
    assert_equal user, @controller.current_user
  end

  test "#sign_in should set the current user" do
    user = Object.new
    @controller.sign_in user

    assert_equal user, @controller.user
  end

  test "#signed_in? should return true when current_user is set" do
    user = Object.new
    @controller.user = user

    assert @controller.signed_in?, "Expected to be signed in"
  end

  test "#signed_in? should return false when current_user is nil" do
    assert_nil @controller.current_user
    refute @controller.signed_in?, "Expected to not be signed in"
  end

  test "#sign_out should set current user to nil" do
    user = Object.new
    @controller.user = user
    @controller.sign_out

    assert_nil @controller.user
  end

  test "#signed_out? should return true when current user is nil" do
    assert_nil @controller.current_user
    assert @controller.signed_out?, "Expected to be signed out"
  end

  test "#signed_out? should return false when current user is set" do
    @controller.current_user = Object.new
    refute @controller.signed_out?, "Expected to not be signed out"
  end

  test "#store_location should store the current path to session when request is GET" do
    @request.path = '/test'
    @controller.store_location

    assert_equal '/test', session[:return_to]
  end

  test "#store_location should not store the current path when request is not GET" do
    @request.path = '/test'
    @request.request_method = 'POST'
    @controller.store_location

    assert_nil session[:return_to]
  end

  test "#store_location should store an arbitrary url if provided" do
    @request.path = '/test'
    @controller.store_location "http://www.everydayhero.com"

    assert_equal "http://www.everydayhero.com", session[:return_to]
  end

  test "#clear_return_to should delete the stored path" do
    session[:return_to] = '/test'
    @controller.clear_return_to

    assert_nil session[:return_to]
  end

  test "#return_to should return the path stored in the session" do
    session[:return_to] = '/test'
    assert_equal @controller.return_to, '/test'
  end

  test "#return_to should return the path stored in the params" do
    @controller.params[:return_to] = '/test'
    assert_equal @controller.return_to, '/test'
  end

  test "#deny_access should raise AuthenticationRequired exception" do
    user = Object.new
    @controller.current_user = user

    assert_raises Gandalf::AuthenticationRequired do
      @controller.deny_access
    end
  end

  test "#deny_access should raise YouShallNotPass exception" do
    user = Object.new
    @controller.current_user = user

    assert_raises Gandalf::YouShallNotPass do
      @controller.deny_access
    end
  end

  test "#authenticate should do nothing when signed in" do
    @controller.current_user = Object.new
    @controller.authenticate
  end

  test "#authenticate should raise exception when signed out" do
    assert_nil @controller.current_user
    assert_raises Gandalf::AuthenticationRequired do
      @controller.authenticate
    end
  end

  test "#authorize! should raise except when cannot perform action" do
    policy = MiniTest::Mock.new
    policy.expect :!, false
    policy.expect :can?, false, [:test, Object]
    object = MiniTest::Mock.new
    object.expect :to_policy, policy

    assert_raises Gandalf::Unauthorized do
      @controller.authorize! :test, object
    end
    assert object.verify
    assert policy.verify
  end

  test "#can? should return true when object has no policy" do
    assert @controller.can?(:test, Object.new)
  end

  test "#can? should pass current_user as the context" do
    user = Object.new
    policy = MiniTest::Mock.new
    policy.expect :!, false
    policy.expect :can?, true, [:test, user]
    object = MiniTest::Mock.new
    object.expect :to_policy, policy
    @controller.current_user = user

    assert @controller.can?(:test, object)
    assert object.verify
    assert policy.verify
  end

  test "#can? should return false when object has a policy but not permission" do
    policy = MiniTest::Mock.new
    policy.expect :!, false
    policy.expect :can?, false, [:test, Object]
    object = MiniTest::Mock.new
    object.expect :to_policy, policy

    refute @controller.can?(:test, object)
    assert object.verify
    assert policy.verify
  end

  test "#can? should call given block when has permission" do
    policy = MiniTest::Mock.new
    policy.expect :!, false
    policy.expect :can?, true, [:test, Object]
    object = MiniTest::Mock.new
    object.expect :to_policy, policy

    block_called = false
    @controller.can?(:test, object) do
      block_called = true
    end

    assert block_called
    assert object.verify
    assert policy.verify
  end

  test "#can? should not call given block when has no permission" do
    policy = MiniTest::Mock.new
    policy.expect :!, false
    policy.expect :can?, false, [:test, Object]
    object = MiniTest::Mock.new
    object.expect :to_policy, policy

    block_called = false
    @controller.can?(:test, object) do
      block_called = true
    end

    refute block_called
    assert object.verify
    assert policy.verify
  end

  test "#cannot? should return false when object has no policy" do
    refute @controller.cannot?(:test, Object.new)
  end

  test "#cannot? should return true when object has policy but not permission" do
    policy = MiniTest::Mock.new
    policy.expect :!, false
    policy.expect :can?, false, [:test, Object]
    object = MiniTest::Mock.new
    object.expect :to_policy, policy

    assert @controller.cannot?(:test, object)
    assert object.verify
    assert policy.verify
  end

  test "#cannot? should return false when object has policy and permission" do
    policy = MiniTest::Mock.new
    policy.expect :!, false
    policy.expect :can?, true, [:test, Object]
    object = MiniTest::Mock.new
    object.expect :to_policy, policy

    refute @controller.cannot?(:test, object)
    assert object.verify
    assert policy.verify
  end

  test "#cannot? should call given block when does not have permission" do
    policy = MiniTest::Mock.new
    policy.expect :!, false
    policy.expect :can?, false, [:test, Object]
    object = MiniTest::Mock.new
    object.expect :to_policy, policy

    block_called = false
    @controller.cannot?(:test, object) do
      block_called = true
    end

    assert block_called
    assert object.verify
    assert policy.verify
  end

  test "#can? should not call given block when does have permission" do
    policy = MiniTest::Mock.new
    policy.expect :!, false
    policy.expect :can?, true, [:test, Object]
    object = MiniTest::Mock.new
    object.expect :to_policy, policy

    block_called = false
    @controller.cannot?(:test, object) do
      block_called = true
    end

    refute block_called
    assert object.verify
    assert policy.verify
  end
end
