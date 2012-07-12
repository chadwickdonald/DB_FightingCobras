class Traffic

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

end