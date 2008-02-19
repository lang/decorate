require "decorate"
require "decorate/create_alias"

module Decorate::Memoize
  
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
