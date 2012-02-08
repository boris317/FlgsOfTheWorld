
module GeoTools
  include Geokit::Geocoders
  
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
  
  def coord_from_name(place_name)
    #Given a place name return [lon,lat]
    results = GoogleGeocoder.geocode(place_name)
    if not results.success
      raise GeoNoResultsFound.new(place_name)
    end
    if results.all.count > 1
      raise GeoManyResultsFound.new(place_name, results.all)
    end
    return results.ll.split(",").map {|a| Float(a)}.reverse
  end
  
  module_function :coord_from_name
end
  
    