require "decorate"

module Decorate::ProtectedMethod
  def protected_method
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
