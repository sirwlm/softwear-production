module Crm
  class Proof < ActiveResource::Base
    include RemoteModel

    self.api_settings_slug = :crm

    # belongs_to :order
    # belongs_to :job

    def status
      begin
        state.humanize
      rescue StandardError => e
        Rails.logger.error "**** ERROR RETRIEVING PROOF INFORMATION (proof.rb) ****\n#{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        'bug_in_the_software_or_bad_data!'
      end
    end
  end
end
