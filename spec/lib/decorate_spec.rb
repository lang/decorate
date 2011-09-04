require 'spec_helper'

describe Decorate do
  let(:before_callback) { mock("BeforeCallback", :call => nil) }
  let(:after_callback)  { mock("AfterCallback",  :call => nil) }

  let(:example_decorator) do
    Module.new do
      def around_filter(before_callback, after_callback)
        Decorate.decorate do |klass, method_name|
          wrapped_method_name = Decorate.create_alias(klass, method_name, :memoize)
          klass.send(:define_method, method_name) do |*args, &block|
            before_callback.call
            send(wrapped_method_name, *args, &block)
            after_callback.call
          end
        end
      end
    end
  end

  let(:decorated_class) do
    example_decorator = self.example_decorator
    before_callback, after_callback = self.before_callback, self.after_callback
    Class.new do
      extend example_decorator
      around_filter(before_callback, after_callback)
      def decorated_method(*args,&block)
        args.each {|x| x.call }
        yield if block_given?
      end
    end
  end

  let(:decorated_object) { decorated_class.new }

  it "should wrap the orignal method" do
    before_callback.should_receive(:call)
    after_callback.should_receive(:call)
    decorated_object.decorated_method
  end

  it "should provide args given to the method" do
    callback_one, callback_two, callback_block = [mock]*3
    callback_one.should_receive(:call)
    callback_two.should_receive(:call)
    callback_block.should_receive(:call)
    decorated_object.decorated_method(callback_one, callback_two) { callback_block.call }
  end
end
