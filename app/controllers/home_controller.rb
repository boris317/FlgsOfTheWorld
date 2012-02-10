class HomeController < ApplicationController
  def index
    @store = FindStoresNearPlaceForm.new
  end
end
