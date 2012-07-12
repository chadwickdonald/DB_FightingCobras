require 'json'

class Ferry
  def initialize(json)
    @json_file = json
  end

  def fare
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

end