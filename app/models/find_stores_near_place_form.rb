class FindStoresNearPlaceForm < ActiveForm::Base
  validates :place_name, :presence => true
  validates :distance, :numericality => true, :presence => true  
end