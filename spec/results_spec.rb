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

end

describe "it should calculate driving costs" do

  it "should know when it's driving over a $5 toll bridge" do
    url = "http://maps.googleapis.com/maps/api/directions/json?origin=Hayward,+CA&destination=San+Mateo,+CA&sensor=false"
    @file = open(url) { |json_file| JSON.parse(json_file.read) }
    @results = Drive_or_bart::Results.new(@file)
    @results.toll_amount.should == 5
  end

  it "should know if it is driving over either the Golden Gate or Bay Bridge toll portions" do
    url = "http://maps.googleapis.com/maps/api/directions/json?origin=Salsalito,+CA&destination=Folsom+St,+CA&sensor=false"
    @file = open(url) { |json_file| JSON.parse(json_file.read) }
    @results = Drive_or_bart::Results.new(@file)
    @results.toll_amount.should == 6
  end

  it "should know the total driving cost assuming 20 mpg and 3.679 dollars/gallon rounded down to 2 decimals" do
    url = "http://maps.googleapis.com/maps/api/directions/json?origin=Salsalito,+CA&destination=Folsom+St,+CA&sensor=false"
    @file = open(url) { |json_file| JSON.parse(json_file.read) }
    @results = Drive_or_bart::Results.new(@file)
    @results.total_cost == 7.89
  end
end

describe "transit parsing" do
  before :all do
    url = "http://maps.googleapis.com/maps/api/directions/json?origin=717+California+St.,+San+Francisco,+CA+94108&destination=1960+Broadway+San+Francisco,+California+94109&mode=transit&sensor=false"
    @file = open(url) { |json_file| JSON.parse(json_file.read) }
    @results = Drive_or_bart::Results.new(@file)
  end

  it "should know the total travel time" do
    @results.travel_time.class.should == Fixnum
  end

  it "should know the total travel distance" do
    @results.travel_distance.class.should == Fixnum
  end

  it "should know when there is walking" do
    @results.walking_distance.class.should == Fixnum
  end

  it "should know the total walking time" do
    @results.walking_time.class.should == Fixnum
  end

end
