module Relevance
  module ModuleExtensions
    # Creates a new method wrapping the previous of
    # the same name, passing it into the block
    # definition of the new method.
    #
    # This can not be used to wrap methods that take
    # a block.
    #
    #   wrap_method( sym ) { |old_meth, *args| 
    #     old_meth.call
    #     ...
    #   }
    #
    def wrap_method( sym, &blk )
      raise ArgumentError, "method does not exist" unless method_defined?( sym ) || private_method_defined?(sym)
      old = instance_method(sym)
      undef_method(sym);
      define_method(sym) { |*args| blk.call(old.bind(self), *args) }
    end
  end
end

Module.class_eval do
  include Relevance::ModuleExtensions
end