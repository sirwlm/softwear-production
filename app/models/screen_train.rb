class ScreenTrain < ActiveRecord::Base
  
  belongs_to :order
  has_many :assigned_screens
  has_many :screens, through: :assigned_screens
  has_many :imprints
  has_many :machines, through: :imprints
  has_many :jobs, through: :imprints
  has_many :screen_requests

  
  def proof_request_data_complete?
    return false if order.blank?
    return false if assigned_screens.empty?
    return false if imprints.empty?
    return false if screen_requests.empty?
    return false if due_at.blank?
    return false if assigned_to.nil?
    return false if garment_material.blank?
    return false if garment_weight.blank?
    return false if artwork_location.blank?
    return false if print_type.blank?
    return true
  end

  def fba?
  end
  

end
