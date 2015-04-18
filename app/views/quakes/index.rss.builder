xml.rss(:version => "2.0", "xmlns:georss"=>"http://www.georss.org/georss") do
  xml.channel do
    xml.title("QuakeMap NZ")
    xml.link("http://www.quakemap.co.nz")
    xml.description("New Zealand's Earthquake Data Visualised")
    xml.language("en-nz")
    @quakes.each do |quake|
      xml.item do
        xml.title(quake.mag_rounded)
        xml.author("http://geonet.org.nz")
        xml.description("Time: #{quake.origin_time.getlocal.strftime("%H:%M:%S %a %d %b %Y")}, Depth: #{quake.depth} km")
        xml.link("http://quakemap.co.nz")
        xml.georss :lat,  quake.coordinates["lat"]
        xml.georss :long, quake.coordinates["lng"]
      end
    end
  end
end
