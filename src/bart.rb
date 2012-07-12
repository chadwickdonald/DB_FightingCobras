require 'crack'
require 'json'
require 'open-uri'

class Bart
  attr_reader :stations
  def initialize(json)
    @json_file = json
    @stations = map_stations
  end

  def fare
    bart_stops
    if @first_stop == "" && @second_stop == ""
      fare = 0
    else
      bart_xml = Crack::XML.parse(open("http://api.bart.gov/api/sched.aspx?cmd=fare&orig=" + @first_stop +"&dest=" + @second_stop + "&key=MW9S-E7SL-26DU-VV8V"))
      fare = bart_xml["root"]["trip"]["fare"].to_f * 100
    end
    fare
  end

  def bart_stops
    @json_file["routes"][0]["legs"][0]["steps"].each do |hash|
      if hash["travel_mode"] == "TRANSIT"
        if hash["html_instructions"].include?("Metro") == true
          @first_stop = @stations[hash["transit_details"]["departure_stop"]["name"]]
          @second_stop = @stations[hash["transit_details"]["arrival_stop"]["name"]]
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

  def map_stations
    {
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