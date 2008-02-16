module Decorate

  VERSION = "0.2.0"

  class BlockDecorator

    def initialize(block)
      @block = block
    end

    def decorate(klass, method_name)
      @block.call(klass, method_name)
    end

  end

  def self.push_decorator(decorator)
    raise TypeError, "#{decorator} not a decorator" unless decorator
    (Thread.current[:_decorator_stack_] ||= []).push(decorator)
  end

  def self.clear_decorators
    stack = (Thread.current[:_decorator_stack_] ||= []).dup
    Thread.current[:_decorator_stack_].clear
    stack
  end

  def self.decorate(decorator = nil, &block)
    if decorator.nil?
      raise "decorator argument or block required" if block.nil?
      decorator = BlockDecorator.new(block)
    elsif block
      raise "won't accept block if decorator argument is given"
    end
    push_decorator(decorator)
  end

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
