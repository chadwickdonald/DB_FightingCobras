require 'simplecov'
SimpleCov.start
require 'rspec'
require 'json'
require '../src/results.rb'
require 'open-uri'

describe "initialization" do
  before :each do
    @results = Drive_or_bart::Results.new("json_file")
  end

  it "is an instance of" do
    @results.should be_an_instance_of Drive_or_bart::Results
  end
end

describe "driving parsing" do
  before :all do
    url = "http://maps.googleapis.com/maps/api/directions/json?origin=San+Francisco&destination=Los+Angeles&sensor=false"
    @file = open(url) { |json_file| JSON.parse(json_file.read) }
    @results = Drive_or_bart::Results.new(@file)
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

  it "should know the total cost"
    #@results.cost.should == 32
end

describe "transit parsing" do
  before :all do
    url = "http://maps.googleapis.com/maps/api/directions/json?origin=717+California+St.,+San+Francisco,+CA+94108&destination=1960+Broadway+San+Francisco,+California+94109&mode=transit&sensor=false"
    @file = open(url) { |json_file| JSON.parse(json_file.read) }
    @results = Drive_or_bart::Results.new(@file)
  end

  it "should know the total travel time" do
    @results.travel_time.should == 1216
  end

  it "should know the total travel distance" do
    @results.travel_distance.should == 2723
  end

  it "should know when there is walking" do
    @results.walking_distance.should == 694
  end

  it "should know the total walking time" do
    @results.walking_time.should == 474
  end

end
