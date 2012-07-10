require_relative 'address'
require 'nokogiri'
require 'open-uri'

class Manager
  attr_reader :origin, :destination
  def initialize(origin, destination)
    @origin = Address.new(origin)
    @destination = Address.new(destination)
  end

  def construct_url(mode_of_transportation)
    "http://maps.googleapis.com/maps/api/directions/json?origin=#{@origin.google_s}&destination=#{@destination.google_s}&sensor=false&mode=#{mode_of_transportation}"
  end

  def document_load
    Nokogiri::HTML(open(construct_url("driving")))
  end

  def getResults
    Array
  #   @results << Result.new(document_load("driving"))
  #   @results << Result.new(document_load("transit"))
  #   @results
  end

end