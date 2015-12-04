module CrmCounterpart
  extend ActiveSupport::Concern

  included do
    after_save :clear_crm
  end

  def crm
    @crm_record ||= begin
      "Crm::#{model_name.name}".constantize.find(softwear_crm_id)
    rescue ActiveResource::ResourceNotFound => e
      nil
    end
  end

  def clear_crm
    @crm_record = nil
  end
end
