require 'json'
require 'crack'
require 'open-uri'
require 'nokogiri'
require_relative 'bart'


module Drive_or_bart
  class Results
    #attr_reader :travel_time
    def initialize(json_file)
      @json_file = json_file
      @muni_check = false
      @bart = Bart.new(@json_file)
      @bart_stations = @bart.stations
    end

    def travel_time
      route_info_finder
      if @transit_counter > 0
        duration = ((@json_file["routes"][0]["legs"][0]["arrival_time"]["value"]) - (@json_file["routes"][0]["legs"][0]["departure_time"]["value"]))
      else
        duration = (@json_file["routes"][0]["legs"][0]["duration"]["value"])
      end
      duration
    end

    def travel_distance
      @json_file["routes"][0]["legs"][0]["distance"]["value"]
    end

    def walking_distance
      route_info_finder
      @walk_distance
    end

    def walking_time
      route_info_finder
      @walk_time
    end

    def toll_amount
      route_info_finder
      @toll_amount
    end

    def driving_cost
      meters = travel_distance
      miles = to_miles(meters)
      gallons = miles / 20
      dollars = 3.679 * gallons
      return ((dollars* 100).floor)

    end

    def muni_checker
      route_info_finder
      @muni_check
    end

    def ferry_fare
      @ferry_fare = 0
      @json_file["routes"][0]["legs"][0]["steps"].each do |hash|
        if hash["travel_mode"] == "TRANSIT"
          if hash["html_instructions"].include?("Ferry towards") == true
            if hash["transit_details"]["line"]["agencies"][0]["name"] == "Baylink"
              @ferry_fare = 1300
            elsif hash["transit_details"]["line"]["agencies"][0]["name"] == "Golden Gate Ferry"
              if hash["transit_details"]["arrival_stop"]["name"] == "Sausalito Ferry Terminal"
                @ferry_fare = 925
              elsif hash["transit_details"]["arrival_stop"]["name"] == "Sausalito Ferry Terminal"
                @ferry_fare = 925
              else
                @ferry_fare = 875
              end
            end
          end
        end
      end
      @ferry_fare
    end

    def total_cost
      cost = driving_cost + ferry_fare + @bart.fare
      if muni_checker == true
        cost = cost + 200
      else
        cost
      end
    end


    private

    def to_miles(meters)
      meters * 0.000621371192
    end

    def route_info_finder
      @transit_counter = 0
      @toll_amount = 0
      @walk_distance = 0
      @walk_time = 0
      @json_file["routes"][0]["legs"][0]["steps"].each do |hash|
        if hash["travel_mode"] == "WALKING"
          @walk_distance += hash["distance"]["value"]
          @walk_time += hash["duration"]["value"]

        elsif hash["travel_mode"] == "DRIVING"
          if (hash["html_instructions"].include?("toll road") == true) && (hash["html_instructions"].include?("US-101") == true)
            @toll_amount = 600
          elsif (hash["html_instructions"].include?("toll road") == true) && (hash["I-80"] == true)
            @toll_amount = 600
          elsif (hash["html_instructions"].include?("toll road") == true)
            @toll_amount = 500
          end
        elsif hash["travel_mode"] == "TRANSIT"
          @transit_counter += 1
          if hash["transit_details"]["line"]["agencies"][0]["name"] == "San Francisco Municipal Transportation Agency"
            @muni_check = true
          end
        end
      end
    end


  end
end
#problem in route_info_founder and travel_time
