$:.unshift "lib"

require "decorate/private_method"
require "decorate/memoize"

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

class M1
  extend Decorate::Memoize

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

  puts "defining class method m1"

  # doesn't work (yet)
  # Must hook into Object#singleton_method_added to make it work!
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

extend Decorate::Memoize

memoize
def mx(a, b)
  puts "#{self}.m1(#{a}, #{b})"
  case [a,b]
  when [1,2]; 1
  when [2,3]; 2
  when [4,5]; 3
  else -1
  end
end

Decorate::Memoize.memoize
def my(a, b)
  puts "#{self}.m1(#{a}, #{b})"
  case [a,b]
  when [1,2]; 1
  when [2,3]; 2
  when [4,5]; 3
  else -1
  end
end

private_method
def private_toplevel_method
  puts "private_toplevel_method called"
end

require "decorate/before_decorator"
class Bf
  extend Decorate::BeforeDecorator

  before_decorator :trace_call, :call => :trace_call

  def trace_call(method_name, *args, &block)
    puts "Before #{self}.#{method_name}, args: #{args.inspect}, block: #{block.inspect}"
  end

  def foo
    puts "foo"
  end

  trace_call
  def bar
    puts "bar"
  end

end
