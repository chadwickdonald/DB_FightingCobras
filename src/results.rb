require 'json'
require 'crack'
require 'open-uri'


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

    def bart_stops
      @json_file["routes"][0]["legs"][0]["steps"].each do |hash|
        if hash["travel_mode"] == "TRANSIT"
          if hash["html_instructions"].include?("Metro") == true
            @first_stop = @bart_stations[hash["transit_details"]["departure_stop"]["name"]]
            @second_stop = @bart_stations[hash["transit_details"]["arrival_stop"]["name"]]
          end
        end
      end
      if @first_stop == nil
        @first_stop = ""
      end
      if @second_stop == nil
        @second_stop = ""
      end
      @first_stop + " " + @second_stop
    end

    def bart_fare
      bart_stops
      bart_xml = Crack::XML.parse(open("http://api.bart.gov/api/sched.aspx?cmd=fare&orig=" + @first_stop +"&dest=" + @second_stop + "&key=MW9S-E7SL-26DU-VV8V"))
      bart_xml["root"]["trip"]["fare"].to_f * 100
    end

    ######## SPIKE CODE START ########################

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
      if muni_checker == true
        driving_cost + ferry_fare + bart_fare + 200
      else
        driving_cost + ferry_fare + bart_fare
      end
    end


    def weather_viewer
      #terms from http://stackoverflow.com/questions/1563884/google-weather-api-conditions
      bad_weather = ["scattered thunderstorms", "showers", "scattered showers", "rain and snow", "light snow", "freezing drizzlse",
        "chance of rain", "chance of storm", "rain", "chance of snow", "storm", "thunderstorm", "chance of tstorm",
        "sleet", "snow", "icy", "flurries", "light rain", "snow showers", "ice/snow", "scattered snow showers"]
      today_weather = []
      url = "http://www.google.com/ig/api?weather=Mountain+View"
      weather_xml = Crack::XML.parse(open(url))
      today_weather << weather_xml["xml_api_reply"]["weather"]["current_conditions"]["condition"]["data"].downcase.inspect
      today_weather << weather_xml["xml_api_reply"]["weather"]["forecast_conditions"][0]["condition"]["data"].downcase.inspect

      today_weather.each do |term|
        term.delete!('\"')
        puts term
      end

      puts today_weather.inspect
      puts bad_weather.inspect
      puts (bad_weather & today_weather).inspect
      if (bad_weather & today_weather).length > 0
        puts "DRIVE!"
      else
        puts "TRANSIT!"
      end

    end

    def traffic_getter
      # scrapes the screen from googlemaps
      url = "http://maps.google.com/maps?q=San+Jose,+CA+to+717+California+st.,+ca"
      doc = Nokogiri::HTML(open(url))
      string = doc.css(".altroute-aux span").first.content
      number_array = []
      number_array += string.scan(/\d/).map!{ |i| i.to_i}
      puts number_array.inspect
      puts number_array[0] * 60 + number_array[1]
    end

    ########## SPIKE CODE END ####################

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
