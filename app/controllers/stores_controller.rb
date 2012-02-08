def error(error_code, error_message, error_info)
  {:error_code => error_code, :error_message => error_message, :error_info => error_info}
end
def json(stores)
  {:count => stores.count, :stores => stores}
end

class StoresController < ApplicationController
  rescue_from ActiveForm::ValidationError, :with => :validation_error_handler
  rescue_from GeoTools::GeoError, :with => :geo_error_handler  
  
  def geo_error_handler(exc)
    if exc.respond_to?("places")
      render :json => error("GEO_AMBIG_LOCATION", "Got multiple results for \"#{exc.place_name}\". Choose one.", exc.places)
    elsif exc.respond_to?("place_name")
      render :json => error("GEO_PLACE_NOT_FOUND", "Could not find location \"#{exc.place_name}\".", exc.place_name)
    else
      raise exc
    end
  end
  
  def validation_error_handler(exc)
    render :json => error("VALIDATION_ERROR", "", exc.errors)
  end
  
  def near_place
    @place = ActiveForm.validate(params, FindStoresNearPlaceForm)
    render(:json => json(Store.find_near(@place.place_name, @place.distance)))
  end
  def near_coord
    @place = ActiveForm.validate(params, FindStoresNearCoordForm)
    render(:json => json(Store.find_near([@place.longitude, @place.latitude], @place.distance)))
  end
end
