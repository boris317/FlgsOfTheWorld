class FindStoresNearCoordForm < ActiveForm::Base
  validates :latitude, :longitude, :numericality => true, :presence => true
  validates :within, :numericality => true, :presence => true
  validates :unit, :inclusion => {:in => %w(km mi KM MI), :message => "%{value} is not a valid unit of distance."}
  
  form_attr_accessor :latitude, longitude, :within, :unit
end