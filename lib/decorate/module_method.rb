require "decorate"

#--
# I'm not sure if module_method is the right name...
#++

module Decorate::ModuleMethod
  def module_method
    Decorate.decorate { |klass, method_name|
      klass.send :module_function, method_name
    }
  end
  private :module_method
end

class Module
  include Decorate::ModuleMethod
end
