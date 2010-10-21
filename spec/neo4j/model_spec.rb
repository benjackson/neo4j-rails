require 'spec_helper'
require 'neo4j/model'

class IceCream < Neo4j::Model
  property :flavour
  property :required_on_create
  property :required_on_update
  property :created
  
  attr_reader :saved
  
  index :flavour
  
  validates :flavour, :presence => true
  validates :required_on_create, :presence => true, :on => :create
  validates :required_on_update, :presence => true, :on => :update
  
  before_create :timestamp
  after_create :mark_saved
  
  protected
  def timestamp
    self.created = "yep"
  end
  
  def mark_saved
    @saved = true
  end
end

class ExtendedIceCream < IceCream
  property :extended_property
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
      subject[:new_attribute] = "newun"
    end
    
    it_should_behave_like "a new model"
    it_should_behave_like "a loadable model"
    it_should_behave_like "a saveable model"
    it_should_behave_like "a creatable model"
    it_should_behave_like "a destroyable model"
    it_should_behave_like "an updatable model"
    
    it "should have the new attribute" do
      subject.attributes.should include(:new_attribute)
      subject.attributes[:new_attribute].should == "newun"
      subject[:new_attribute].should == "newun"
    end
    
    context "after being saved" do
      before { Neo4j::Transaction.run { subject.save } }
      
      it { should == subject.class.find(:flavour => "vanilla") }
      
      it "should render as XML" do
        subject.to_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <flavour>vanilla</flavour>\n  <required-on-create>true</required-on-create>\n  <required-on-update>true</required-on-update>\n  <created>yep</created>\n  <new-attribute>newun</new-attribute>\n</hash>\n"
      end
      
      it "should be able to modify one of its named attributes" do
        Neo4j::Transaction.run do
          lambda{ subject.update_attributes!(:flavour => 'horse') }.should_not raise_error
        end
        subject.flavour.should == 'horse'
      end
      
      it "should have the flavour property" do
        subject.class.properties_info.should include(:flavour)
      end
      
      it "should not have the extended property" do
        subject.class.properties_info.should_not include(:extended_property)
      end
      
      it "should have the new attribute" do
        subject.attributes.should include(:new_attribute)
        subject.attributes[:new_attribute].should == "newun"
        subject[:new_attribute].should == "newun"
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
        Neo4j::Transaction.run { @obj = subject.class.create!(subject.attributes) }
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

describe "ExtendedIceCream" do
  context "when valid" do
    subject { ExtendedIceCream.new(:flavour => "vanilla", :required_on_create => "true", :required_on_update => "true") }
    
    it_should_behave_like "a new model"
    it_should_behave_like "a loadable model"
    it_should_behave_like "a saveable model"
    it_should_behave_like "a creatable model"
    it_should_behave_like "a destroyable model"
    it_should_behave_like "an updatable model"
    
    context "after being saved" do
      before { Neo4j::Transaction.run { subject.save } }
      
      it { should == subject.class.find(:flavour => "vanilla") }
    end
  end
end