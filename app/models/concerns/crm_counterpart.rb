module CrmCounterpart
  extend ActiveSupport::Concern

  included do
    cattr_accessor :crm_class
    after_save :clear_crm

    begin
      self.crm_class = "Crm::#{name}".constantize
    rescue NameError => _
    end
  end

  def crm
    @crm_record ||= begin
      self.class.crm_class.find(softwear_crm_id)
    rescue ActiveResource::ResourceNotFound => _
      nil
    end
  end

  def clear_crm
    @crm_record = nil
  end
end
