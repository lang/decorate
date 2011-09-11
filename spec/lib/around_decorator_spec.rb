require 'spec_helper'

describe Decorate, "around decorator" do
  let(:before_callback) { mock("BeforeCallback", :call => nil) }
  let(:after_callback)  { mock("AfterCallback",  :call => nil) }

  let(:example_decorator) do
    Module.new do
      def around_filter(before_callback,after_callback)
        Decorate.around_decorator do |call|
          before_callback.call(call)
          call.transfer
          after_callback.call(call)
        end
      end
    end
  end

  let(:decorated_object) do
    decorator, before_cb, after_cb = self.example_decorator, self.before_callback, self.after_callback
    Class.new do
      extend decorator
      around_filter(before_cb, after_cb)
      def decorated_method(*args,&block)
        args.each {|x| x.call("from method") }
        yield if block_given?
        "String"
      end
    end.new
  end

  subject { decorated_object }

  it "should wrap the orignal method" do
    before_callback.should_receive(:call)
    after_callback.should_receive(:call)
    subject.decorated_method
  end

  it "should provide args to the original method" do
    callback_one, callback_two, callback_block = [mock]*3
    callback_one.should_receive(:call)
    callback_two.should_receive(:call)
    callback_block.should_receive(:call)
    subject.decorated_method(callback_one, callback_two) { callback_block.call }
  end

  describe "call object" do

    it "should be passed to the decorator on call" do
      before_callback.should_receive(:call).with { |call| call.should be_a Decorate::AroundCall }
      subject.decorated_method
    end

    it "should contain receiver for the original call" do
      before_callback.should_receive(:call).with { |call| call.receiver.should == subject }
      subject.decorated_method
    end

    it "should contain args for the original call" do
      args = [:a, :b].map{|x| mock(x, :call => nil) }
      before_callback.should_receive(:call).with { |call| call.args.should == args }
      subject.decorated_method(*args)
    end

    it "should contain block for the original call" do
      block = lambda {}
      before_callback.should_receive(:call).with { |call| call.block.should == block }
      subject.decorated_method(&block)
    end

    it "should contain original name of the method" do
      before_callback.should_receive(:call).with { |call| call.message.should == :decorated_method }
      subject.decorated_method
    end

    it "should contain result of the call" do
      after_callback.should_receive(:call).with { |call| call.result.should == "String" }
      subject.decorated_method
    end

    it "should contain alias name of the original method" do
      before_callback.should_receive(:call).with do |call|
        call.wrapped_message.should == :decorated_method_without_around_decorator
      end
      subject.decorated_method
    end

  end

end
