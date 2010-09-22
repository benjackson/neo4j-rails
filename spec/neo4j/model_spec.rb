require File.expand_path('../../spec_helper', __FILE__)
require 'neo4j/model'

class IceCream < Neo4j::Model
  property :flavour
  property :required_on_create
  property :required_on_update
  property :created, :type => DateTime
  
  attr_reader :saved
  
  index :flavour
  
  validates :flavour, :presence => true
  validates :required_on_create, :presence => true, :on => :create
  validates :required_on_update, :presence => true, :on => :update
  
  before_create :timestamp
  after_create :mark_saved
  
  protected
  def timestamp
    self.created = DateTime.now
  end
  
  def mark_saved
    @saved = true
  end
end

describe Neo4j::Model do
  it_should_behave_like "a new model"
  it_should_behave_like "a loadable model"
  it_should_behave_like "a saveable model"
  it_should_behave_like "a creatable model"
  it_should_behave_like "a destroyable model"
  it_should_behave_like "an updatable model"
end

describe IceCream do
  context "when valid" do
    before :each do
      subject.flavour = "vanilla"
      subject.required_on_create = "true"
      subject.required_on_update = "true"
    end
    
    it_should_behave_like "a new model"
    it_should_behave_like "a loadable model"
    it_should_behave_like "a saveable model"
    it_should_behave_like "a creatable model"
    it_should_behave_like "a destroyable model"
    it_should_behave_like "an updatable model"
    
    context "after being saved" do
      before { txn { subject.save } }
      
      it "should find a model by one of its attributes" do
        subject.class.find(:flavour => "vanilla").to_a.should include(subject)
      end
      
      context "and then made invalid" do
        before { subject.required_on_update = nil }
        
        it "shouldn't be updatable" do
          subject.update_attributes(:flavour => "fish").should_not be_true
        end
        
        it "should have the same attribute values after an unsuccessful update" do
          subject.update_attributes(:flavour => "fish")
          subject.reload.flavour.should == "vanilla"
        end
      end
    end
    
    context "after create" do
      before :each do
        txn { @obj = subject.class.create!(subject.attributes) }
      end
      
      it "should have run the #timestamp callback" do
        @obj.created.should_not be_nil
      end
      
      it "should have run the #mark_saved callback" do
        @obj.saved.should_not be_nil
      end
    end
  end
  
  context "when invalid" do
    it_should_behave_like "a new model"
    it_should_behave_like "an unsaveable model"
    it_should_behave_like "an uncreatable model"
    it_should_behave_like "a non-updatable model"
  end
end
