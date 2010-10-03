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
    
    it "should allow properties to be accessed with a symbol" do
      lambda{ subject.props[:test] = true }.should_not raise_error
    end
  end
end

share_examples_for "a loadable model" do
  context "when saved" do
    before :each do
      Neo4j::Transaction.run { subject.save }
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
    
    context "while inside a transaction", :type => :neo4j_transaction do
      
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
    include ActiveModel::Lint::Tests
    
    before :each do
      Neo4j::Transaction.run { subject.save }
      @model = subject
    end
    
    it { should be_persisted }
    it { should == subject.class.load(subject.id) }
    
    it "should be found in the database" do
      Neo4j::Transaction.run { subject.class.all.should include(subject) }
    end
    
    it "should respond to attributes as well as props" do
      subject.attributes.should == subject.props
    end
    
    it "should respond to primary_key" do
      subject.class.should respond_to(:primary_key)
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
      Neo4j::Transaction.run { subject.save }
    end
    
    it "should remove the model from the database" do
      Neo4j::Transaction.run { subject.destroy }
      Neo4j::Transaction.run { subject.class.load(subject.id).should be_nil }
    end
  end
end

share_examples_for "a creatable model" do
  context "when attempting to create", :type => :neo4j_transaction do
    
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
  context "when attempting to create", :type => :neo4j_transaction do
    
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
    before { Neo4j::Transaction.run { subject.save } }
    
    context "and updated" do
      it "should have altered attributes" do
        Neo4j::Transaction.run { subject.update_attributes(:a => 1, :b => 2).should be_true }
        Neo4j::Transaction.run { subject[:a].should == 1; }
        Neo4j::Transaction.run { subject[:b].should == 2; }
      end
    end
  end
end

share_examples_for "a non-updatable model" do
  context "then" do
    it "shouldn't update" do
      Neo4j::Transaction.run { subject.update_attributes({ :a => 3 }).should_not be_true }
    end
  end
end