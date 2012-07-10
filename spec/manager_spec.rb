require 'rspec'
require '../src/manager.rb'
require '../src/address.rb'
require 'json'

describe Manager do
  before :each do
    @manager = Manager.new("1525 Sutter St 94109", "668 N Rengstorff 94043")
  end

  it "should be an instance of the Manager class" do
    @manager.should be_an_instance_of Manager
  end

  it "should take the 2 arguments and instantiate them as Address objects" do
    @manager.origin.should be_an_instance_of Address
    @manager.destination.should be_an_instance_of Address
  end

  it "should set the correct parameter to origin" do
    @manager.origin.address.should eq "1525 Sutter St 94109"
  end

  it "should set the correct parameter to destination" do
    @manager.destination.address.should eq "668 N Rengstorff 94043"
  end

  context "#construct_url" do
    it "should have a construct_url method" do
      @manager.should respond_to :construct_url
    end

    it "should properly construct the api call url using the origin and destination" do
      @manager.construct_url("driving").should eq "http://maps.googleapis.com/maps/api/directions/json?origin=1525+Sutter+St+94109&destination=668+N+Rengstorff+94043&sensor=false&mode=driving"
      @manager2 = Manager.new("555 W Middlefield Rd", "123 Abc St.")
      @manager2.construct_url("driving").should eq "http://maps.googleapis.com/maps/api/directions/json?origin=555+W+Middlefield+Rd&destination=123+Abc+St.&sensor=false&mode=driving"
    end
  end

  context "#document_load" do
    it "should have a method that loads the results of the API call into a Nokogiri::HTML::Document" do
      @manager.document_load.class.should be Nokogiri::HTML::Document
    end

    it "should return a parsable result with information relavant to the origin and destination" do
       a = JSON.parse(@manager.document_load)
       a["routes"][0]["legs"][0]["distance"]["value"].should eq 58536
     end
    end

  context "#getResults" do
    it "should have a getResults method" do
      @manager.should respond_to :getResults
    end

    it "should return a result with a travel time" do
      mock_result = double('result')
      mock_result.should_receive(:to_s).match("time = 37 minutes")
    end

  end






end