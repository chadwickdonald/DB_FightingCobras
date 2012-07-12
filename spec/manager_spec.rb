require 'rspec'
require 'json'
require 'fakeweb'
require '../src/manager.rb'
require '../src/address.rb'
require '../src/results.rb'

FakeWeb.allow_net_connect = false

describe Manager do
  before :each do
    # Manager.all_instances.stub(:document_load).and_return(File.read('./driving_directions.json'), File.read('./transit_directions.json'))
    @manager = Manager.new("1525 Sutter St 94109", "668 N Rengstorff 94043")
  end

  it "should set the correct parameter to origin" do
    @manager.origin.to_s.should eq "1525 Sutter St 94109"
  end

  it "should set the correct parameter to destination" do
    @manager.destination.to_s.should eq "668 N Rengstorff 94043"
  end

  context "#get_best" do
    before :each do
      @manager.stub(:document_load).and_return(JSON.parse(File.read('./driving_directions.json')), JSON.parse(File.read('./transit_directions.json')) )

    end

    it "should have a get_best method" do
      @manager.should respond_to :get_best
    end

    it "should return a hash with at least one Results object in it" do
       #@manager.get_best[:driving].stub(:open).and_return(File.read('./bart_from_dbrk_to_embr.xml'))
       @manager.get_best[:driving].should be_an_instance_of Drive_or_bart::Results
     end

    it "should return the cheapest Results object" do
      @manager.get_best[:cheapest].should eq @manager.driving_results
    end

    it "should return the quickest Results object" do
      @manager.get_best[:fastest].should eq @manager.driving_results
    end

    it "should return four Results objects within a hash" do
      @manager.get_best.should be_an_instance_of Hash
      result_count = 0
      @manager.get_best.each_value {|value| result_count += 1 if value.class == Drive_or_bart::Results}
      result_count.should be == 4
    end
  end

  # context "#document_load" do
  #    before :each do
  #      @manager.should_receive(:open).and_return(File.read('./driving_directions.json'))
  #    end
  #
  #    it "should have a method that loads the results of the API call into parsed file" do
  #      @manager.document_load("driving").class.should be String
  #    end
  #
  #    it "should return a parsable result with information relavant to the origin and destination" do
  #      a = JSON.parse(@manager.document_load("driving"))
  #      #puts a["routes"][0]["legs"][0]["distance"]["value"]
  #      a["routes"][0]["legs"][0]["distance"]["value"].should eq 58536
  #    end
  #  end
  #
  #  context "#get_results" do
  #    before :each do
  #      @manager.stub(:document_load).and_return(File.read('./driving_directions.json'), File.read('./transit_directions.json'))
  #      # Manager.all_instances.stub(:document_load).and_return(File.read('./driving_directions.json'), File.read('./transit_directions.json'))
  #    end
  #
  #    it "should have a getResults method" do
  #      @manager.should respond_to :get_results
  #    end
  #
  #    it "should return an array of two results" do
  #      @manager.get_results
  #      @manager.results[0].should be_an_instance_of Drive_or_bart::Results
  #      @manager.results[1].should be_an_instance_of Drive_or_bart::Results
  #    end
  #  end
end