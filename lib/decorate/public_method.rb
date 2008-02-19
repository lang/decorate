require "decorate"

module Decorate::PublicMethod
  def public_method
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
