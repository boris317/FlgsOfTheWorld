class FindStoresNearCoordForm < ActiveForm::Base
  validates :latitude, :longitude, :numericality => true, :presence => true
  validates :distance, :numericality => true, :presence => true    
end