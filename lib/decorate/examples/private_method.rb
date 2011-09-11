require "decorate"

module Decorate::PrivateMethod

  # private_method decorator - makes the next defined method private.
  # Can be used at the module-, class- and toplevel.
  #
  # Examples:
  #
  #   require "decorate/private_method"
  #
  #   class Foo
  #     private_method
  #     def bar
  #       puts "Foo#bar called"
  #     end
  #     def foo
  #       bar
  #     end
  #   end
  #   f = Foo.new
  #   f.foo # Foo#bar called
  #   f.bar # NoMethodError: private method `bar' called for #<Foo:0xb7be2f64>
  #
  #   my_object = Object.new
  #   private_method
  #   def my_object.foo
  #     puts "foo"
  #   end
  #   my_object.foo # => NoMethodError: private method `foo' called for #<Object:0xb7bdce20>
  #
  #   private_method
  #   Foo.send(:define_method, :baz) { puts "baz" }
  #   f.baz # => NoMethodError: private method `baz' called for #<Foo:0xb7ba7d38>
  def private_method #:doc:
    Decorate.decorate { |klass, method_name|
      klass.send :private, method_name
    }
  end
  private :private_method

end

# Make private_method available at the class/module level.
class Module
  include Decorate::PrivateMethod
end

# Make private_method available at the toplevel.
extend Decorate::PrivateMethod
