require 'open-uri'
class QuakeService
  def self.rapid
    JSON.parse open('http://geonet.org.nz/quakes/services/all.json').read
  end

  def self.felt
    JSON.parse open('http://geonet.org.nz/quakes/services/felt.json').read
  end

  def self.unique(publicid)
    uri = "http://geonet.org.nz/quakes/services/quake/#{publicid}.json"
    JSON.parse open(uri).read
  end
end
