require "decorate"
require "decorate/create_alias"

# This module is highly experimental and might change significantly or
# be removed completely since its usefulness is highly questionable in
# its current form.
module Decorate::BeforeDecorator

  # Example:
  #
  #   require "decorate/before_decorator"
  #
  #   class Bf
  #     extend Decorate::BeforeDecorator
  #
  #     before_decorator :trace_call, :call => :trace_call
  #
  #     def trace_call(method_name, *args, &block)
  #       puts "Before #{self}.#{method_name}, args: #{args.inspect}, block: #{block.inspect}"
  #     end
  #
  #     def foo
  #       puts "foo"
  #     end
  #
  #     trace_call
  #     def bar
  #       puts "bar"
  #     end
  #
  #   end
  #
  #   >> o = Bf.new
  #   >> o.foo
  #   foo
  #   >> o.bar
  #   Before #<Bf:0xb7b32dbc>.bar, args: [], block: nil
  #   bar
  def before_decorator(decorator_name, opts) #:doc:
    before_method_name = opts[:call]
    unless before_method_name.kind_of?(Symbol)
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
            self.__send__(:#{before_method_name},
                          :#{method_name}, *args, &block)
            self.__send__(:#{wrapped_method_name},
                          *args, &block)
          end
        EOF
      }
    }
  end
  private :before_decorator

end
