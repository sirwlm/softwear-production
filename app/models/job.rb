class Job < ActiveRecord::Base
  include CrmCounterpart
  include TrainStation

  has_one :imprintable_train, dependent: :destroy
  has_one :preproduction_notes_train, dependent: :destroy
  has_one :shipment_train, as: :shipment_holder, dependent: :destroy
  has_many :custom_ink_color_trains, dependent: :destroy
  has_many :imprints, dependent: :destroy
  belongs_to :order

  accepts_nested_attributes_for :imprints, allow_destroy: true
  accepts_nested_attributes_for :imprintable_train, allow_destroy: true

  after_save :assign_preproduction_notes_train

  def full_name
    if softwear_crm_id.blank?
      "#{order.full_name} - #{name}" rescue name
    else
      "#{order.full_name} - #{name} - CRMJob ##{softwear_crm_id}" rescue name
    end
  end

  def imprint_state
    if imprints.where(completed_at: nil).size == 0
      'Printed'
    else
      'Pending'
    end
  end

  def production_state
    trains.all?(&:complete?) ? 'Complete' : 'Pending'
  end

  private

  def assign_preproduction_notes_train
    # TODO ...
    # self.preproduction_notes_train ||= PreproductionNotesTrain.new
  end
end
