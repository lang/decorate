module Decorate

  # A BlockDecorator instance wraps an object (+block+) and delegates
  # calls to +decorate+ to the wrapped objects +call+ method.
  class BlockDecorator

    def initialize(block)
      @block = block
    end

    def decorate(klass, method_name)
      @block.call(klass, method_name)
    end

  end

  # Push a decorator on the current threads decorator stack.
  # A decorator is an object that responds to +decorate+ taking a
  # class and a method name (symbol) as arguments.
  def self.push_decorator(decorator)
    raise TypeError, "#{decorator} not a decorator" unless decorator
    (Thread.current[:_decorator_stack_] ||= []).push(decorator)
  end

  # Clear the current threads decorator stack. Returns the old stack
  # as an Enumerable.
  def self.clear_decorators
    stack = (Thread.current[:_decorator_stack_] ||= []).dup
    Thread.current[:_decorator_stack_].clear
    stack
  end

  # Add a decorator that will be applied to the next method
  # definition. Either pass an object that responds to
  # decorate(klass, method_name) or a block. The block will be wrapped
  # in a BlockDecorator.
  #
  # Example:
  #
  #   def trace_def
  #     Decorate.decorate { |klass, method_name|
  #       puts "Method #{method_name.inspect} defined in #{klass.inspect}"
  #     }
  #   end
  #
  #   class Foo
  #     trace_def
  #     def bar
  #       # ...
  #     end
  #   end
  #   # prints: Method :bar defined in Foo
  def self.decorate(decorator = nil, &block)
    if decorator.nil?
      raise "decorator argument or block required" if block.nil?
      decorator = BlockDecorator.new(block)
    elsif block
      raise "won't accept block if decorator argument is given"
    end
    push_decorator(decorator)
  end

  # Apply the current threads decorator stack to the specified method.
  #
  # Decorate hooks into Module#method_added and
  # Object#singleton_method_added to call this method.
  def self.process_decorators(klass, method_name)
    Decorate.clear_decorators.reverse!.each { |decorator|
      decorator.decorate(klass, method_name)
    }
  end

end

class Module

  private

  alias _method_added_without_decorate method_added

  def method_added(method_name)
    #puts "method_added: #{self.inspect}[#{object_id}] #{method_name}"
    _method_added_without_decorate(method_name)
    Decorate.process_decorators(self, method_name)
  end

end

class Object

  private

  alias _singleton_method_added_without_decorate singleton_method_added

  def singleton_method_added(method_name)
    _singleton_method_added_without_decorate(method_name)
    klass = class << self; self; end
    #puts "singleton_method_added: #{klass.inspect}[#{klass.object_id}] #{method_name}"
    Decorate.process_decorators(klass, method_name)
  end

end
