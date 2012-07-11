require 'open-uri'
require 'crack'
require 'nokogiri'

def ferry_fare
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
  url = "http://maps.google.com/maps?q=San+Jose,+CA+to+717+California+st.,+ca"
  doc = Nokogiri::HTML(open(url))
  string = doc.css(".altroute-aux span").first.content
  number_array = []
  number_array += string.scan(/\d/).map!{ |i| i.to_i}
  puts number_array.inspect
  puts number_array[0] * 60 + number_array[1]
end
