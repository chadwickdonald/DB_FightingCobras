require 'rspec'
require '../src/address.rb'

describe Address do

  before :each do
    @address = Address.new("123 Fake St., San Francisco, CA 94110")
    @address2 = Address.new("1600 Pennsylvania Ave., Washington, DC 12345")
  end

  it "should create an instance of Address" do
    @address.should be_an_instance_of Address
  end

  it "should have an instance variable called address" do
    @address.address.should eq "123 Fake St., San Francisco, CA 94110"
    @address2.address.should eq "1600 Pennsylvania Ave., Washington, DC 12345"
  end

  it "should have a #google_s method" do
    @address.should respond_to :google_s
  end

  it "#google_s should turn any address into a URL friendly string" do
    @address.google_s.should eq "123+Fake+St.,+San+Francisco,+CA+94110"
  end


end