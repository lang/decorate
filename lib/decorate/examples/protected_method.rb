require "decorate"

module Decorate::ProtectedMethod
  # protected_method decorator - makes the next defined method
  # protected. Otherwise works like
  # Decorate::PrivateMethod#private_method.
  def protected_method #:doc:
    Decorate.decorate { |klass, method_name|
      klass.send :protected, method_name
    }
  end
  private :protected_method
end

class Module
  include Decorate::ProtectedMethod
end

extend Decorate::ProtectedMethod
