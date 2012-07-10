require 'json'


module Drive_or_bart
  class Results
    # attr_reader :travel_time
    def initialize(json_file)
      @json_file = json_file
    end

    def travel_time
      @json_file["routes"][0]["legs"][0]["duration"]["value"]
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

    def total_cost
      meters = travel_distance
      miles = to_miles(meters)
      gallons = miles / 20
      dollars = 3.679 * gallons
      return ((dollars* 100).floor) / 100.0

    end



    private

    def to_miles(meters)
      meters * 0.000621371192
    end

    def route_info_finder
      @toll_amount = 0
      @walk_distance = 0
      @walk_time = 0
      @json_file["routes"][0]["legs"][0]["steps"].each do |hash|
        if hash["travel_mode"] == "WALKING"
          @walk_distance += hash["distance"]["value"]
          @walk_time += hash["duration"]["value"]

        elsif hash["travel_mode"] == "DRIVING"
          if (hash["html_instructions"].include?("toll road") == true) && (hash["html_instructions"].include?("US-101") == true)
            @toll_amount = 6
          elsif (hash["html_instructions"].include?("toll road") == true) && (hash["I-80"] == true)
            @toll_amount = 6
          elsif (hash["html_instructions"].include?("toll road") == true)
            @toll_amount = 5
          end
        end
      end
    end

  end
end
