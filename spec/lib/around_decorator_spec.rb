require 'spec_helper'

describe Decorate, "around decorator" do
  let(:before_callback) { mock("BeforeCallback", :call => nil) }
  let(:after_callback)  { mock("AfterCallback",  :call => nil) }

  let(:example_decorator) do
    Module.new do
      def around_filter(before_callback,after_callback)
        Decorate.around_decorator do |call|
          before_callback.call(call)
          call.yield
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

  it "should preserve the return value of original method" do
    subject.decorated_method.should == "String"
  end

  describe "call object" do
    let(:args) { [:a, :b].map{|x| mock(x, :call => nil) } }

    let(:block) { lambda {} }

    subject do
      call_object = nil
      after_callback.stub(:call).with {|co| call_object = co }
      decorated_object.decorated_method(*args,&block)
      call_object
    end

    it { should be_a Decorate::AroundCall }

    specify { subject.receiver.should == decorated_object }

    specify { subject.args.should == args }

    specify { subject.block.should == block }

    specify { subject.message.should == :decorated_method }

    specify { subject.result.should == "String" }

    specify { subject.wrapped_message.should == :decorated_method_without_around_filter }

  end

end
