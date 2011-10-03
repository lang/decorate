module Decorate

  # Create a private alias for the instance method named +method_name+
  # of class +klass+. The string representation of +id+ will be part
  # of the alias to ease debugging. This method makes sure that the
  # alias doesn't redefine an existing method.
  #
  # Returns the name of the new alias.
  #
  # In the simplest case, the alias will be
  # <tt>"#{method_name}_without_#{id}"</tt>.
  def self.create_alias(klass, method_name, id)
    basename = "#{method_name}_without_#{id}"

    i = 0
    new_name = basename
    loop {
      break unless klass.method_defined?(new_name) or klass.private_method_defined?(new_name) 
      i += 1
      new_name = "#{basename}_#{i}"
    }

    klass.send(:alias_method, new_name, method_name)
    klass.send(:private, new_name)
    new_name
  end

end
