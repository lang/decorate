require "spec_helper"
require File.expand_path("../../docsrc/examples/memoize", File.dirname(__FILE__))


describe Decorate::Memoize do
  subject do
    Class.new do
      extend Decorate::Memoize

      memoize
      def call(n, m = 0)
        self.send("call_#{n + m}")
      end

      def call_1; 1; end
      def call_2; 2; end
      def call_3; 3; end

    end.new
  end

  it "should memoize the value for a given input" do
    subject.should_receive(:call_1).once.and_return(1)
    subject.call(1).should == 1
    subject.call(1).should == 1
  end

  it "should memoize the value for more inputs" do
    subject.should_receive(:call_2).twice.and_return(2)
    subject.call(1,1).should == 2
    subject.call(1,1).should == 2
    subject.call(2,0).should == 2
    subject.call(2,0).should == 2
  end
end
