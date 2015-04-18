class Quake
  include Mongoid::Document
  include Mongoid::Timestamps

  field :origin_time,   type: ActiveSupport::TimeWithZone
  field :update_time,   type: ActiveSupport::TimeWithZone
  field :magnitude,     type: Float
  field :depth,         type: Float
  field :public_id,     type: String
  field :status,        type: String
  field :coordinates,   type: Hash
  field :felt,          type: Boolean, default: false

  index({ public_id: 1 }, { unique: true })
  index origin_time: 1
  index magnitude: 1
  index status: 1

  alias_attribute :external_id, :public_id

  def self.search(opts)
    between(origin_time: opts[:start_time]..opts[:end_time])
      .sort(origin_time: -1)
  end

  def origin_time=(time)
    super Time.parse("#{time} UTC")
  end

  def update_time=(time)
    super Time.parse("#{time} UTC")
  end

  def refresh_data!
    feature = QuakeService.unique(public_id)['features'].first
    if feature.present?
      self.origin_time = feature['properties']['origintime']
      self.update_time = feature['properties']['updatetime']
      self.depth       = feature['properties']['depth']
      self.magnitude   = feature['properties']['magnitude']
      self.status      = feature['properties']['status']
      self.coordinates = {
        lat: feature['geometry']['coordinates'][1],
        lng: feature['geometry']['coordinates'][0]
      }

      save!
    end
  end

  def mag_rounded
    (magnitude * 10).round / 10.0
  end

  def as_geo_json
    {
      geometry: {
        type: 'Point',
        coordinates: [coordinates['lng'], coordinates['lat']]
      },
      properties: {
        magnitude: magnitude,
        depth: depth,
        time: origin_time.getlocal.strftime('%H:%M:%S %a %d %b %Y'),
        reference: external_id
      }
    }
  end

  def self.pull_rapid
    Quake.where(status: 'automatic', felt: false).destroy_all
    QuakeService.rapid['features'].each do |feature|
      quake = Quake.find_or_initialize_by(
        public_id: feature['properties']['publicid'])

      quake.origin_time = feature['properties']['origintime']
      quake.update_time = feature['properties']['updatetime']
      quake.depth       = feature['properties']['depth']
      quake.magnitude   = feature['properties']['magnitude']
      quake.status      = feature['properties']['status']
      quake.coordinates = {
        lat: feature['geometry']['coordinates'][1],
        lng: feature['geometry']['coordinates'][0]
      }
      quake.save!
    end
  end

  def self.pull_felt
    QuakeService.felt['features'].each do |feature|
      quake = Quake.find_or_initialize_by(
        public_id: feature['properties']['publicid'])

      quake.origin_time = feature['properties']['origintime']
      quake.update_time = feature['properties']['updatetime']
      quake.depth       = feature['properties']['depth']
      quake.magnitude   = feature['properties']['magnitude']
      quake.status      = feature['properties']['status']
      quake.coordinates = {
        lat: feature['geometry']['coordinates'][1],
        lng: feature['geometry']['coordinates'][0]
      }
      quake.felt        = true
      quake.save!
    end
  end

  def self.pull_data
    Quake.pull_rapid
    Quake.pull_felt
  end
end
