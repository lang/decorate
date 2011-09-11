require "decorate"

#--
# I'm not sure if module_method is the right name...
#++

module Decorate::ModuleMethod

  # module_method decorator - makes the next defined method a module
  # function. This decorator is available at the class and module
  # level. The effect is the same as calling Module#module_function
  # with the method name after the method definition.
  #
  # Example:
  #
  #   require "decorate/module_method"
  #
  #   module Shell
  #
  #     module_method
  #     def sh(command)
  #       system(command)
  #     end
  #
  #   end
  #
  # is equivalent to:
  #
  #   module Shell
  #
  #     def sh(command)
  #       system(command)
  #     end
  #     module_function :sh
  #
  #   end
  #
  # In this example, +sh+ is now a method of the +Shell+ object as
  # well as an instance method of the +Shell+ module. Read <tt>ri
  # Module#module_function</tt> for more details.
  def module_method #:doc:
    Decorate.decorate { |klass, method_name|
      klass.send :module_function, method_name
    }
  end
  private :module_method
  
end

class Module
  include Decorate::ModuleMethod
end
