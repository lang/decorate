require "decorate"

class Module

  def private_method
    Decorate.decorate { |klass, method_name|
      klass.send :private, method_name
    }
  end
  private :private_method

end
