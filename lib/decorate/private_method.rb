require "decorate"

module Decorate::PrivateMethod
  def private_method
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
