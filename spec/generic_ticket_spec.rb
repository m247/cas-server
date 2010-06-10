require 'spec_helper'

shared_examples_for "GenericTicket" do
  describe ".prefix" do
    it "should respond to .prefix" do
      @klass.should respond_to(:prefix)
    end
  end
  describe ".valid_prefix?" do
    it "is true if string starts with prefix" do
      @klass.valid_prefix?("#{@klass.prefix}-BLAH").should be_true
    end
    it "is false if string doesn't start with prefix" do
      @klass.valid_prefix?('FL-WHALE').should be_false
    end
  end
  describe ".generate" do
    it "should generate different output" do
      @klass.generate.should_not == @klass.generate
    end
    it "generates a value with the prefix" do
      @klass.valid_prefix?(@klass.generate).should be_true
    end
  end
  describe "#name" do
    it "should not begin with :prefix" do
      ticket = @klass.new
      ticket.name.should match(/^#{@klass.prefix}/)
    end
    it "should have #{GenericTicket::TICKET_LENGTH} characters" do
      ticket = @klass.new
      ticket.name.should have(GenericTicket::TICKET_LENGTH).characters
    end
  end
  describe "#created_at" do
    it "should be now" do
      ticket = @klass.new
      ticket.created_at.to_i.should == Time.now.utc.to_i
    end
  end
  describe "#to_s" do
    it "gives the ticket name" do
      ticket = @klass.new
      ticket.name.should == ticket.to_s
    end
  end
end
