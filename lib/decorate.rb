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

end

class Module

  private

  alias _method_added_without_decorate method_added

  def method_added(method_name)
    _method_added_without_decorate(method_name)
    loop {
      decorator = Decorate.pop_decorator
      break if decorator.nil?
      decorator.decorate(self, method_name)
    }
  end

end
