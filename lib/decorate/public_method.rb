require "decorate"

module Decorate::PublicMethod
  # public_method decorator - makes the next defined method public.
  # Otherwise works like Decorate::PrivateMethod#private_method.
  def public_method #:doc:
    Decorate.decorate { |klass, method_name|
      klass.send :public, method_name
    }
  end
  private :public_method
end

class Module
  include Decorate::PublicMethod
end

extend Decorate::PublicMethod
