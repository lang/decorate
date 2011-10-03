require 'spec_helper'

describe Decorate, "create_alias" do
  subject do
    Class.new do
      def hello_world
        "Hello World"
      end
    end
  end

  it "should create alias for a method in class" do
    Decorate.create_alias(subject,:hello_world, :alias)
    subject.new.send(:hello_world_without_alias).should == "Hello World"
  end

  it "should handle duplicities for more aliases" do
    Decorate.create_alias(subject,:hello_world, :alias)
    Decorate.create_alias(subject,:hello_world, :alias)
    subject.new.send(:hello_world_without_alias).should == "Hello World"
    subject.new.send(:hello_world_without_alias_1).should == "Hello World"
  end

end
