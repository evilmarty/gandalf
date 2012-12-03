module Gandalf
  class Policy
    attr_reader :model

    def initialize model
      @model = model
    end

    alias_method :to_model, :model

    def can? action, context = nil
      method = "can_#{action}?"
      respond_to?(method) && public_send(method, context)
    end

    def cannot? *args
      !can? *args
    end

    def self.can *actions, &block
      raise ArgumentError, "Must specify at least one action" if actions.empty?
      raise ArgumentError, "A block must be given" if block.nil?
      raise ArgumentError, "Block must accept one argument" unless block.arity == 1

      actions.flatten.each do |action|
        define_method "can_#{action}?", &block
      end
    end
  end
end