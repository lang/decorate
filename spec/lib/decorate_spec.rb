require 'spec_helper'

describe Decorate do
  let(:callback) { mock("BeforeCallback", :call => nil) }

  let(:example_decorator) do
    Module.new do
      def decor(callback)
        Decorate.decorate do |klass, method_name|
          wrapped_method_name = Decorate.create_alias(klass, method_name, :decor)
          callback.call(klass, method_name)
          klass.send(:define_method, method_name) do |*args, &block|
            send(wrapped_method_name, *args, &block)
          end
        end
      end
    end
  end

  let(:example_decorator_from_module) do
    Module.new do
      def decor(callback)
        decor_module = Module.new do
          @callback = callback
          def self.decorate(klass, method_name)
            wrapped_method_name = Decorate.create_alias(klass, method_name, :decor)
            @callback.call(klass, method_name)
            klass.send(:define_method, method_name) do |*args, &block|
            send(wrapped_method_name, *args, &block)
            end
          end
        end
        Decorate.decorate(decor_module)
      end
    end
  end

  let(:decorated_class) do
    decorator, callback = self.example_decorator, self.callback
    Class.new do
      class << self; def self.mock_id; "123" end end

      extend decorator
      decor(callback)
      def self.decorated_method(*args,&block); end

      def self.tes
        "test"
      end
    end
  end

  let(:decorated_class_from_module) do
    decorator, callback = self.example_decorator_from_module, self.callback
    Class.new do
      class << self; def self.mock_id; "123" end end

      extend decorator
      decor(callback)
      def self.decorated_method(*args,&block); end

      def self.tes
        "test"
      end
    end
  end

  let(:decorated_object) do
    decorator, callback = self.example_decorator, self.callback
    Class.new do
      class << self; def mock_id; "123" end end

      extend decorator
      decor(callback)
      def decorated_method(*args,&block); end
    end.new
  end

  shared_examples_for "with decorated method" do
    it "should be triggered after method is defined" do
      self.callback.should_receive(:call)
      subject
    end

    it "should pass the method's class" do
      self.callback.should_receive(:call).with do |klass, method_name|
        klass.mock_id.should == "123"
      end
      subject
    end

    it "should pass the method's name" do
      self.callback.should_receive(:call).with do |klass, method_name|
        method_name == :decorated_method
      end
      subject
    end
  end

  context("instance method") do
    subject { decorated_object }
    it_should_behave_like "with decorated method"
  end

  context("class method") do
    subject{ decorated_class }
    it_should_behave_like "with decorated method"
  end

  context("class method from module") do
    subject{ decorated_class_from_module }
    it_should_behave_like "with decorated method"
  end

  describe "defining decorator with module and block at once" do
    subject do
      decorator = Module.new do; def decorate(klass, method_name); end; end
      Decorate.decorate(decorator) {|klass, method_name| }
    end

    specify { lambda { subject}.should raise_error(/won\'t accept block if decorator argument is given/) }
  end
end
