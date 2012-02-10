
include GeoTools
class Store
  include MongoMapper::Document
  attr_accessor :distance
    
  key :name, String
  key :description, String
  key :loc, Array #[lon, lat]
  ensure_index [[:loc,'2d']]  
  
  def longitude
    self.loc[0]
  end
  def latitude
    self.loc[1]
  end
  
  def longitude=(val)
    self.loc[0] = val
  end
  def latitude=(val)
    self.loc[1] = val
  end
    
  def initialize
    @distance = nil
  end
  
  def self.find_near(place, range, unit=:mi)
    radius = get_earch_radius(unit)
    
    case place
    when Array
      geo_place = GeoPlace.new("", place)
    when String
      geo_place = geo_place_from_name(place)
    end
    lat, lon = geo_place.latitude, geo_place.longitude
    
    results = where(:loc => { '$nearSphere' => [lon, lat], '$maxDistance' => Float(range) / radius }).all.map do |s|
      s.distance = s.distance_from(lat, lon, unit); s
    end
    
    return {
      :place => {
        :name => geo_place.name,
        :point => geo_place.point
      },
      :unit_of_distance => unit,
      :count => results.count,
      :stores =>  results
    }
    
  end
  def distance_from(lat, lon, unit=nil)
    distance_between(self, GeoPlace.new("", [lat,lon]), unit)
  end
  def to_s
    "<Store #{self.name}>"
  end
  
  def as_json(options={})
    obj = super(options)
    if not distance.nil?
      obj[:distance] = distance
    end
    obj.delete(:loc)
    obj[:point] = { :latitude => latitude, :longitude => longitude }
    return obj
  end
end
