require "decorate"
require "decorate/create_alias"

module Decorate::Memoize
  
  # A naive memoization decorator, using a plain Hash as cache.
  #
  # Example usage:
  #
  #   require "decorate/memoize"
  #
  #   Decorate::Memoize.memoize
  #   def factorial(n)
  #     n == 0 ? 1 : n * factorial(n - 1)
  #   end
  #   factorial(7) # => 5040
  #
  # Memoization takes the arguments as well as the instance itself
  # into account. You can also extend a module/class with
  # Decorate::Memoize to leave off the module prefix. Note that this
  # decorator doesn't work for methods that take a block.
  def memoize
    Decorate.decorate { |klass, method_name|
      wrapped_method_name = Decorate.create_alias(klass, method_name, :memoize)
      # TODO: should use weak hash tables
      cache = Hash.new { |hash, key| hash[key] = {} }
      klass.send(:define_method, method_name) { |*args|
        icache = cache[self]
        if icache.has_key?(args)
          icache[args]
        else
          icache[args] = send(wrapped_method_name, *args)
        end
      }
    }
  end
  module_function :memoize

end
