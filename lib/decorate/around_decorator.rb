require "decorate"
require "decorate/create_alias"

module Decorate::AroundDecorator

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
    attr_reader :result

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
  
  def around_decorator(decorator_name, opts) #:doc:
    around_method_name = opts[:call]
    unless around_method_name.kind_of?(Symbol)
      raise "Option :call with Symbol argument required"
    end
    unkown_opt = opts.keys.find { |opt| ![:call].include?(opt) }
    if unkown_opt
      raise "Unknown option #{unknown_opt.inspect}"
    end

    self.class.send(:define_method, decorator_name) {
      Decorate.decorate { |klass, method_name|
        wrapped_method_name =
          Decorate.create_alias(klass, method_name, decorator_name)
        klass.class_eval <<-EOF, __FILE__, __LINE__
          def #{method_name}(*args, &block)
            call = Decorate::AroundDecorator::AroundCall.new(
                     self, :#{method_name}, :#{wrapped_method_name},
                     args, block)
            __send__(:#{around_method_name}, call)
          end
        EOF
      }
    }
  end
  private :around_decorator

end
