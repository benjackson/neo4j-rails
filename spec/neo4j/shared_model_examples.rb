share_examples_for "a new model" do
  context "when unsaved" do
    it { should_not be_persisted }
  
    it "should allow direct access to properties before it is saved" do
      subject["fur"] = "none"
      subject["fur"].should == "none"
    end
    
    it "should allow access to all properties before it is saved" do
      subject.props.should be_a(Hash)
    end
  end
end

share_examples_for "a loadable model" do
  context "when saved" do
    before :each do
      txn { subject.save }
    end
    
    it "should load a previously stored node" do
      result = subject.class.load(subject.id)
      result.should == subject
      result.should be_persisted
    end
  end
end

share_examples_for "a saveable model" do
  context "when attempting to save" do
    it "should fail to save new model without a transaction" do
      lambda { subject.save }.should raise_error(NativeException)
    end
    
    context "while inside a transaction" do
      use_transactions
      
      it "should save ok" do
        subject.save.should be_true
      end
        
      it "should save without raising an exception" do
        subject.save!.should_not raise_error(Neo4j::Model::RecordInvalidError)
      end
    end
  end
  
  context "after being saved" do
    # make sure it looks like an ActiveModel model
    include_tests ActiveModel::Lint::Tests
    
    before :each do
      txn { subject.save }
      @model = subject
    end
    
    it { should be_persisted }
    it { should == subject.class.load(subject.id) }
    
    it "should be found in the database" do
      txn { subject.class.all.should include(subject) }
    end
    
    it "should respond to attributes as well as props" do
      subject.attributes.should == subject.props
    end
  end
end

share_examples_for "an unsaveable model" do 
  context "when attempting to save" do
    it "should not save ok" do
      subject.save.should_not be_true
    end
    
    it "should raise an exception" do
      lambda { subject.save! }.should raise_error(Neo4j::Model::RecordInvalidError)
    end
  end
  
  context "after attempted save" do
    before { subject.save }
    
    it { should_not be_valid }
    it { should_not be_persisted }
    
    it "should have a nil id after save" do
      subject.id.should be_nil
    end
  end
end

share_examples_for "a destroyable model" do
  context "when saved" do
    before :each do
      txn { subject.save }
    end
    
    it "should remove the model from the database" do
      txn { subject.destroy }
      txn { subject.class.load(subject.id).should be_nil }
    end
  end
end

share_examples_for "a creatable model" do
  context "when attempting to create" do
    use_transactions
    
    it "should create ok" do
      subject.class.create(subject.attributes).should be_true
    end
    
    it "should not raise an exception on #create!" do
      lambda { subject.class.create!(subject.attributes) }.should_not raise_error(Neo4j::Model::RecordInvalidError)
    end
    
    it "should save the model and return it" do
      model = subject.class.create(subject.attributes)
      model.should be_persisted
    end
  
    it "should accept attributes to be set" do
      model = subject.class.create :name => "Ben"
      model[:name].should == "Ben"
    end
  end
end

share_examples_for "an uncreatable model" do
  context "when attempting to create" do
    use_transactions
    
    it "shouldn't create ok" do
      subject.class.create.persisted?.should_not be_true
    end
    
    it "should raise an exception on #create!" do
      lambda { subject.class.create! }.should raise_error(Neo4j::Model::RecordInvalidError)
    end
  end
end

share_examples_for "an updatable model" do
  context "when saved" do
    before { txn { subject.save } }
    
    context "and updated" do
      before {  }
      
      it "should have altered attributes" do
        txn { subject.update_attributes(:a => 1, :b => 2).should be_true }
        txn { subject[:a].should == 1; }
        txn { subject[:b].should == 2; }
      end
    end
  end
end

share_examples_for "a non-updatable model" do
  context "then" do
    it "shouldn't update" do
      txn { subject.update_attributes({ :a => 3 }).should_not be_true }
    end
  end
end