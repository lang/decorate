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

end
