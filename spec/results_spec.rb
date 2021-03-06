require 'simplecov'
SimpleCov.start
require 'rspec'
require 'json'
require 'fakeweb'
require '../src/results.rb'
require 'open-uri'

# FakeWeb.allow_net_connect = false

describe "initialization" do
  before :each do
    @driving_hash = JSON.parse(File.read('./driving_from_hayward_to_sm.json'))
    @results = Drive_or_bart::Results.new(@driving_hash, "Driving", 10)
  end

  it "is an instance of" do
    @results.should be_an_instance_of Drive_or_bart::Results
  end
end

describe "driving parsing" do
  before :all do
    @driving_hash = JSON.parse(File.read('./driving_from_SF_to_LA.json'))
    @results = Drive_or_bart::Results.new(@driving_hash,"Driving", 10)
  end

  it "should know the total travel time" do
    @results.travel_time.should == 23160
  end

  it "should know the total travel distance" do
    @results.travel_distance.should == 613877
  end

  it "should know when there's no walking" do
    @results.walking_distance.should == 0
  end

  it "should know the total walking time" do
    @results.walking_time.should == 0
  end

end

describe "it should calculate driving costs" do

  it "should know when it's driving over a $5 toll bridge" do
    @driving_hash = JSON.parse(File.read('./driving_from_hayward_to_sm.json'))
    @results = Drive_or_bart::Results.new(@driving_hash,"Driving", 10)
    @results.toll_amount.should == 500
  end

  it "should know if it is driving over either the Golden Gate or Bay Bridge toll portions" do
    @driving_hash = JSON.parse(File.read('./driving_from_salsalito_to_folsom_st.json'))
    @results = Drive_or_bart::Results.new(@driving_hash,"Driving", 10)
    @results.toll_amount.should == 600
  end

  it "should know the total driving cost assuming 20 mpg and 3.679 dollars/gallon rounded down to 2 decimals" do
    @driving_hash = JSON.parse(File.read('./driving_from_salsalito_to_folsom_st.json'))
    @results = Drive_or_bart::Results.new(@driving_hash,"Driving", 10)
    @results.stub(:open).and_return(File.read('./bart_from_dbrk_to_embr.xml'))
    @results.total_cost == 789
  end
end

describe "transit parsing" do
  before :all do
    @transit_hash = JSON.parse(File.read('./transit_from_california_to_broadway.json'))
    @results = Drive_or_bart::Results.new(@transit_hash,"Transit", 0)
  end

  it "should know the total travel time including time spent waiting at bus stops" do
    @results.travel_time.should == 1223
  end

  it "should know the total travel distance" do
    @results.travel_distance.should == 2723
  end

  it "should know when there is walking and how much total distance was walked" do
    @results.walking_distance.should == 694
  end

  it "should know the total walking time" do
    @results.walking_time.should == 474
  end

  it "should calculate muni costs appropriately" do
    @results.muni_checker.should == true
  end
end

describe "transit cost estimation" do
  before :all do
    @transit_hash = JSON.parse(File.read('./transit_from_sutter_to_SFO.json'))
    @results = Drive_or_bart::Results.new(@transit_hash,"Transit", 0)
  end

  it "should know the cost of a trip involving a bart and muni" do
    @results.total_cost.should == 1025
  end








end





# weather_viewer and traffic_getter call internet

