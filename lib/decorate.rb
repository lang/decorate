module Decorate

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

  def self.pop_decorator
    (Thread.current[:_decorator_stack_] ||= []).pop
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
    loop {
      decorator = Decorate.pop_decorator
      break if decorator.nil?
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
