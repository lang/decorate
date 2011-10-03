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
    Decorate.around_decorator do |call|
      @_memoize ||= Hash.new {|h,k| h[k] = {} }
      unless @_memoize[call.message].has_key?(call.args)
        @_memoize[call.message][call.args] = call.yield
      end
      call.result = @_memoize[call.message][call.args]
    end
  end
  module_function :memoize

end
