$:.unshift "lib"

require "decorate/private_method"

class Foo

  def foo
    puts "foo"
    bar
  end

  private_method
  def bar
    puts "bar"
  end

end

module Memoize
  
  def memoize
    Decorate.decorate { |klass, method_name|
      wrapped_method_name = :"#{method_name}_without_memoize"
      klass.send :alias_method, wrapped_method_name, method_name
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

end

class M1
  extend Memoize

  memoize
  def m1(a, b)
    puts "#{self}.m1(#{a}, #{b})"
    case [a,b]
    when [1,2]; 1
    when [2,3]; 2
    when [4,5]; 3
    else -1
    end
  end

  # doesn't work (yet)
  memoize
  def self.m1(a, b)
    puts "#{self}.m1(#{a}, #{b})"
    case [a,b]
    when [1,2]; 1
    when [2,3]; 2
    when [4,5]; 3
    else -1
    end
  end

end
