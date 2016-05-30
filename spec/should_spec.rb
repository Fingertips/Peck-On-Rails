require 'preamble'

Record = Struct.new(:id)

describe Peck::Should do
  describe "equal_record_set" do
    it "equals a record set" do
      spec = Peck::Should.new([Record.new(id: 1)])
      spec.equal_record_set([Record.new(id: 1)]).should == true
    end

    it "does not equal a record set" do
      spec = Peck::Should.new([Record.new(id: 1)])
      lambda {
        spec.equal_record_set([Record.new(id: 2)]).should == true
      }.should.raise(Peck::Error)
    end

    it "compares sets" do
      record = Record.new(id: 1)
      Peck::Should.new([record, record]).equal_record_set([record]).should == true
      Peck::Should.new([record]).equal_record_set([record, record]).should == true
    end

    it "flattens sets" do
      record = Record.new(id: 1)
      Peck::Should.new([[record]]).equal_record_set([record]).should == true
      Peck::Should.new([record]).equal_record_set([[record]]).should == true
    end
  end

  describe "equal_record_array" do
    it "equals a record array" do
      spec = Peck::Should.new([Record.new(id: 1)])
      spec.equal_record_set([Record.new(id: 1)]).should == true
    end

    it "does not equal a record array" do
      spec = Peck::Should.new([Record.new(id: 1)])
      lambda {
        spec.equal_record_set([Record.new(id: 2)]).should == true
      }.should.raise(Peck::Error)
    end
  end

  describe "equal_set" do
    it "equals a record set" do
      spec = Peck::Should.new([1])
      spec.equal_set([1]).should == true
    end

    it "does not equal a record set" do
      spec = Peck::Should.new([1])
      lambda {
        spec.equal_set([2]).should == true
      }.should.raise(Peck::Error)
    end

    it "compares sets" do
      Peck::Should.new([1,1]).equal_set([1]).should == true
      Peck::Should.new([1]).equal_set([1,1]).should == true
    end

    it "flattens sets" do
      record = Record.new(id: 1)
      Peck::Should.new([[record]]).equal_set([record]).should == true
      Peck::Should.new([record]).equal_set([[record]]).should == true
    end
  end
end
