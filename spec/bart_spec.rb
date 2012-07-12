require 'rspec'
require 'json'
require 'fakeweb'
require '../src/bart.rb'
require 'open-uri'

FakeWeb.allow_net_connect = false


describe "bart api" do

  before :all do
    @transit_hash = JSON.parse(File.read('./transit_from_center_to_california.json'))
    @bart = Bart.new(@transit_hash)
  end

  it "should return the correct bart stations" do
    @bart.bart_stops.should == "dbrk embr"

  end
  it "should handle the bart api" do
    @bart.stub(:open).and_return(File.read('./bart_from_dbrk_to_embr.xml'))
    @bart.fare.should == 370
  end

end