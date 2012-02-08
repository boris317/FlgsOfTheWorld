include GeoTools

EARTH_RADIUS_KM = 6371
EARTH_RADIUS_MI = 3959

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
  
  def self.find_near(place, range, unit=nil)
    radius = self.get_unit(unit)
    
    case place
    when Array
      lon, lat = place
    when String
      lon, lat = coord_from_name(place)
    end
    
    where(:loc => {'$nearSphere' => [lon, lat], '$maxDistance' => Float(range) / radius}).all.each do |s|
      s.distance = s.distance_from(lat, lon, unit)
    end
    
  end
  
  def distance_from(lat, lon, unit=nil)

    r = Store.get_unit(unit)
    long_1 = self.longitude * Math::PI / 180 
    lat_1  = self.latitude * Math::PI / 180 

    long_2 = lon * Math::PI / 180
    lat_2  = lat * Math::PI / 180 

    dlong = long_2 - long_1
    dlat = lat_2 - lat_1
    a = (Math.sin(dlat / 2))**2 + Math.cos(lat_1) * Math.cos(lat_2) * (Math.sin(dlong / 2))**2
    c = 2 * Math.asin([1, Math.sqrt(a)].min)
    dist = r * c
    
  end
  
  def self.get_unit(unit)
    if unit == :mi or unit.nil?
      EARTH_RADIUS_MI
    elsif unit == :km
      EARTH_RADIUS_KM
    end  
  end
  
  def to_s
    "<Store #{self.name}>"
  end
  
end
