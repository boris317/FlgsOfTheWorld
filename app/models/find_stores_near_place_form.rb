class FindStoresNearPlaceForm < ActiveForm::Base
  validates :near, :presence => true
  validates :within, :numericality => true, :presence => true
  validates :unit, :presence => true, 
    :inclusion => {:in => %w(km mi KM MI), :message => "%{value} is not a valid unit of distance."}
  
  form_attr_accessor :near, :within, :unit
end