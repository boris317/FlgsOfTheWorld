
module GeoTools
  include Geokit::Geocoders
  
  EARTH_RADIUS_KM = 6371
  EARTH_RADIUS_MI = 3959
  
  class GeoError < StandardError; end
  
  class GeoManyResultsFound < GeoError
    attr_accessor :places, :place_name
    def initialize(place_name, places)
      @places = places
      @place_name = place_name
    end
  end
  
  class GeoNoResultsFound < GeoError
    attr_accessor :place_name    
    def intialize(place_name)
      @place_name = place_name
    end
  end
  
  class GeoPlace
    attr_accessor :name, :latitude, :longitude
    
    def initialize(name, coords)
      @name = name
      @latitude = coords[0]
      @longitude = coords[1]
    end
      
    def point
      {:latitude => @latitude, :longitude => @longitude}
    end
  end
      
  def geo_place_from_name(place_name)
    #Given a place name return [lon,lat]
    results = GoogleGeocoder.geocode(place_name)
    if not results.success
      raise GeoNoResultsFound.new(place_name)
    end
    if results.all.count > 1
      raise GeoManyResultsFound.new(place_name, results.all)
    end
    return GeoPlace.new(results.full_address, results.ll.split(",").map {|a| Float(a)})
  end
  
  def distance_between(geo_place_a, geo_place_b, unit=nil)

    r = get_earch_radius(unit)
    long_1 = geo_place_a.longitude * Math::PI / 180 
    lat_1  = geo_place_a.latitude * Math::PI / 180 

    long_2 = geo_place_b.longitude * Math::PI / 180
    lat_2  = geo_place_b.latitude * Math::PI / 180 

    dlong = long_2 - long_1
    dlat = lat_2 - lat_1
    a = (Math.sin(dlat / 2))**2 + Math.cos(lat_1) * Math.cos(lat_2) * (Math.sin(dlong / 2))**2
    c = 2 * Math.asin([1, Math.sqrt(a)].min)
    dist = r * c
    
  end
    
  def get_earch_radius(unit)
    if unit == :km
      EARTH_RADIUS_KM
    else
      EARTH_RADIUS_MI      
    end  
  end  
  
  module_function :geo_place_from_name, :distance_between, :get_earch_radius
end
  
    