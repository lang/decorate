require "decorate"
require "decorate/create_alias"

module Decorate

  # An AroundCall holds the auxiliary information that is passed as
  # argument to an around method.
  class AroundCall

    # Receiving object.
    attr_reader :receiver

    # The message that was sent resulting in this around call.
    attr_reader :message

    # The name of the method that constitutes the "core" behaviour
    # (behaviour without the around logic).
    attr_reader :wrapped_message

    # Original argument list.
    attr_reader :args

    # Original block.
    attr_reader :block

    # Holds the result of a transfer to the wrapped method.
    attr_accessor :result

    def initialize(receiver, message, wrapped_message, args, block)
      @receiver = receiver
      @message = message
      @wrapped_message = wrapped_message
      @args = args
      @block = block
      @result = nil
    end

    # Call the wrapped method. +args+ and +block+ default to original
    # ones passed by client code. The return value of the wrapped
    # method is stored in the +result+ attribute and also returned
    # from transfer.
    def transfer(args = @args, &block)
      block ||= @block
      @result = @receiver.__send__(@wrapped_message, *args, &block)
    end

  end
  
  # Example:
  #   
  #   class Ad
  #     def self.wrap
  #       Decorate.around_decorator do |call|
  #         puts "Before #{call.inspect}"
  #         call.transfer
  #         puts "After #{call.inspect}"
  #         call.result += 1
  #       end
  #     end
  #   
  #     wrap
  #     def foo(*args, &block)
  #       puts "foo: #{args.inspect}, block: #{block.inspect}"
  #       rand 10
  #     end
  #   
  #   end
  #
  #   >> o = Ad.new
  #   => <Ad:0xb7bd1e80>
  #   >> o.foo
  #   Before #<Decorate::AroundDecorator::AroundCall:0xb7bd0828 @message=:foo, @result=nil, @receiver=#<Ad:0xb7bd1e80>, @args=[], @block=nil, @wrapped_message=:foo_without_wrap>
  #   foo: [], block: nil
  #   After #<Decorate::AroundDecorator::AroundCall:0xb7bd0828 @message=:foo, @result=5, @receiver=#<Ad:0xb7bd1e80>, @args=[], @block=nil, @wrapped_message=:foo_without_wrap>
  #   => 6
  def self.around_decorator(decorator_name = nil, &decorator_block) #:doc:
    Decorate.decorate do |klass, method_name|
      decorator_name ||= eval("__method__", decorator_block.binding)
      wrapped_method_name = Decorate.create_alias(klass, method_name, decorator_name)
      klass.send(:define_method, method_name) do |*args, &block|
        call = Decorate::AroundCall.new(self, method_name.to_sym, wrapped_method_name.to_sym, args, block)
        decorator_block.call(call)
        call.result
      end
    end
  end

end
