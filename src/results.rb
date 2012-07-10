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
      @walk_distance = 0
      @json_file["routes"][0]["legs"][0]["steps"].each do |hash|
        if hash["travel_mode"] == "WALKING"
          @walk_distance += hash["distance"]["value"]
        end
      end
      return @walk_distance
    end

    def walking_time
      @walk_time = 0
      @json_file["routes"][0]["legs"][0]["steps"].each do |hash|
        if hash["travel_mode"] == "WALKING"
          @walk_time += hash["duration"]["value"]
        end
      end
      return @walk_time
    end
  end
end
