module CrmCounterpart
  extend ActiveSupport::Concern

  included do
    model_name = name.underscore

    validates :softwear_crm_id, presence: true, uniqueness: true

    class_eval <<-RUBY, __FILE__, __LINE__
      def crm_#{model_name}
        @crm_#{model_name} ||= Crm::#{name}.find(softwear_crm_id)
      end
    RUBY

  end
end