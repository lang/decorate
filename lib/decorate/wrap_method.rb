require "decorate"

module Decorate

  # NOTE: This class will probably be removed and only
  # the wrapped_method_name logic will be preserved.

  class WrapMethod

    # A name for the decorator that is used for name mangling
    # and thus has mostly significance for debugging.
    attr_reader :name

    attr_reader :block

    attr_reader :klass, :method_name

    # The name argument is used to initialize the +name+ attribute.
    def initialize(name, &block)
      @name = name
      @block = block
      @klass = nil
      @method_name = nil
      @wrapped_method_name = nil
    end

    def initialized?
      @klass && @method_name
    end

    def decorate(klass, method_name)
      @klass = klass
      @method_name = method_name
    end

    def wrapped_method_name
      raise "not initialized yet" unless initialized?
      return @wrapped_method_name if @wrapped_method_name
      basename = "#{@method_name}_without_#{@name}"

      i = 0
      try_name = basename
      loop {
        break unless @klass.method_defined?(try_name)
        i += 1
        try_name = "#{basename}_#{i}"
      }

      @wrapped_method_name = try_name
    end

    def make_alias
      klass.alias_method(wrapped_method_name, method_name)
    end

  end

end
