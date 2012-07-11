require 'json'
require 'crack'


module Drive_or_bart
  class Results
    #attr_reader :travel_time
    def initialize(json_file)
      @json_file = json_file
      @muni_check = false
      bart_hash
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

    def total_cost
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

    def bart_stops
      @json_file["routes"][0]["legs"][0]["steps"].each do |hash|
        if hash["travel_mode"] == "TRANSIT"
          if hash["html_instructions"].include?("Metro") == true
            @first_stop = @bart_stations[hash["transit_details"]["departure_stop"]["name"]]
            @second_stop = @bart_stations[hash["transit_details"]["arrival_stop"]["name"]]
          end
        end
      end
      @first_stop + " " + @second_stop
    end

    def bart_fare
      bart_stops
      bart_xml = Crack::XML.parse(open("http://api.bart.gov/api/sched.aspx?cmd=fare&orig=" + @first_stop +"&dest=" + @second_stop + "&key=MW9S-E7SL-26DU-VV8V"))
      puts bart_xml["root"]["trip"]["fare"]
      bart_xml["root"]["trip"]["fare"].to_i * 100
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

    def bart_hash
      @bart_stations = {
        "12th St. Oakland City Center"        => "12th",
        "16th St. Mission"                    => "16th",
        "19th St. Oakland"                    => "19th",
        "24th St. Mission"                    => "24th",
        "Ashby"                               => "ashb",
        "Balboa Park"                         => "balb",
        "Bay Fair (San Leandro)"              => "bayf",
        "Castro Valley"                       => "cast",
        "Civic Center"                        => "civc",
        "Coliseum/Oakland Airport"            => "cols",
        "Colma"                               => "colm",
        "Concord"                             => "conc",
        "Daly City"                           => "daly",
        "Downtown Berkeley"                   => "dbrk",
        "Dublin/Pleasanton"                   => "dubl",
        "El Cerrito del Norte"                => "deln",
        "El Cerrito Plaza"                    => "plza",
        "Embarcadero"                         => "embr",
        "Fremont"                             => "frmt",
        "Fruitvale"                           => "ftvl",
        "Glen Park"                           => "glen",
        "Hayward"                             => "hayw",
        "Lafayette"                           => "lafy",
        "Lake Merritt"                        => "lake",
        "MacArthur"                           => "mcar",
        "Millbrae"                            => "mlbr",
        "Montgomery St."                      => "mont",
        "North Berkeley"                      => "nbrk",
        "North Concord/Martinez"              => "ncon",
        "Orinda"                              => "orin",
        "Pittsburg/Bay Point"                 => "pitt",
        "Pleasant Hill"                       => "phil",
        "Powell St."                          => "powl",
        "Richmond"                            => "rich",
        "Rockridge"                           => "rock",
        "San Bruno"                           => "sbrn",
        "San Francisco Int'l Airport"         => "sfia",
        "San Leandro"                         => "sanl",
        "South Hayward"                       => "shay",
        "South San Francisco"                 => "ssan",
        "Union City"                          => "ucty",
        "Walnut Creek"                        => "wcrk",
        "West Oakland"                        => "woak"
      }
    end

  end
end
