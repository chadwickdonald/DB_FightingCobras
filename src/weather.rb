
class Weather


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

end