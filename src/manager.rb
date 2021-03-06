require_relative 'address'
require_relative 'results'
require 'open-uri'
require 'json'

class Manager
  attr_reader :origin, :destination, :driving_results, :transit_results
  def initialize(origin, destination, parking_cost = 0, other_preferences = {})
    @origin = Address.new(origin)
    @destination = Address.new(destination)
    @driving_results = nil
    @transit_results = nil
    @parking_cost = parking_cost.to_f * 100
  end

  def get_best
      get_results
      return_hash = { :driving => @driving_results,
                      :transit => @transit_results,
                      :cheapest => "",
                      :fastest => ""}

      return_hash[:fastest] = fastest
      return_hash[:cheapest] = cheapest
      return_hash

  end

  private
  def document_load(mode_of_transportation)
    google = "http://maps.googleapis.com/maps/api/directions/json?"
    origin = "origin=#{@origin.google_s}"
    destination = "&destination=#{@destination.google_s}"
    sensor = "&sensor=false"
    mode = "&mode=#{mode_of_transportation}"
    url = google + origin + destination + sensor + mode
    file = open(url).read
    JSON.parse(file)
  end

  def valid_address?(mode_of_transportation)
    file = document_load(mode_of_transportation)
    if file[:status] != "ZERO_RESULTS"
      true
    else
      false
    end
  end

  def get_results
    @driving_results = Drive_or_bart::Results.new(document_load("driving"),"Driving", @parking_cost)
    @transit_results = Drive_or_bart::Results.new(document_load("transit"),"Transit", @parking_cost)
  end

  def fastest
    if @driving_results.travel_time > @transit_results.travel_time
      @transit_results
    else
      @driving_results
    end
  end

  def cheapest
    if @driving_results.total_cost > @transit_results.total_cost
      @transit_results
    else
      @driving_results
    end
  end
end