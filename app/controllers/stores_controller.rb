def error(error_code, error_message, error_info)
  {:error_code => error_code, :error_message => error_message, :error_info => error_info}
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
    @store = exc.form
    respond_to do |format|
      format.html { render :action => '/home#index' }
      format.json { render :json => error("VALIDATION_ERROR", "", exc.form.errors) }
    end
  end
  
  def near_place
    #render :json => params[:store]
    Rails.logger.error(params.class.to_s)
    @store = ActiveForm.validate(params[:store], FindStoresNearPlaceForm)
    @stores = Store.find_near(@store.near, @store.within, unit=@store.unit.to_sym)

    respond_to do |format|
      format.html
      format.json { render :json => @stores }
    end
  end
  def near_coord
    @store = ActiveForm.validate(params[:store], FindStoresNearCoordForm)
    render(:json => json(Store.find_near([@place.longitude, @place.latitude], @store.within, unit=@store.unit)))
  end
end
