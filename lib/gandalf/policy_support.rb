require 'active_support/inflector'

module Gandalf
  module PolicySupport
    def to_policy
      "#{self.class.name}Policy".constantize.new self
    rescue NameError
      nil
    end
  end
end