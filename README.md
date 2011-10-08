# decorate

[Homepage](http://github.com/lang/decorate)

## Description

Python style decorators for Ruby.

## Usage

* Basic decorator

```ruby
require 'decorate'

module UpperCaser
  def upper
    Decorate.decorate do |klass, method_name|
      wrapped_method_name = Decorate.create_alias(klass, method_name, :decor)
      klass.send(:define_method, method_name) do |*args, &block|
        send(wrapped_method_name, *args, &block).to_s.upcase
      end
    end
  end
end

class HelloWorld
  extend UpperCaser

  upper
  def say_hello
    "Hello World"
  end

  upper
  def self.say_hello
    "Hello World"
  end
end
HelloWorld.new.say_hello # => "HELLO WORLD"
HelloWorld.say_hello # => "HELLO WORLD"
```

* Around decorator
  
The same upper example with aound rdecorator:

```ruby
require 'decorate'

module UpperCaser
  def upper
    Decorate.around_decorator do |call|
      call.yield
      call.result = call.result.to_s.upcase
    end
  end
end
```

* Memoize (example decorator, see docsrc/examples/memoize.rb)

```ruby
require 'decorate'

class Fact
  extend Decorate::Memoize

  memoize
  def factorial(n)
    return n == 0 ? 1 : n*factorial(n-1)
  end
end
```

## Hygiene issues

Decorate hooks into (aka redefines) Module#method_added and
Object#singleton_method_added via the classic alias/delegate pattern.
If you override these methods in one of your classes that use
decorators, make sure to call +super+, otherwise decorate breaks.

## License

Decorate is licensed under the same terms as the main Ruby
implementation. See http://www.ruby-lang.org/en/LICENSE.txt.
