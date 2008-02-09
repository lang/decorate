$:.unshift "lib"

require "decorate/private_method"

class Foo
  def foo
    puts "foo"
    bar
  end
  private_method
  def bar
    puts "bar"
  end
end
