namespace :imprints do
  task fix_names: :environment do
    Imprint.all.each do |imprint|
      next if imprint.job.blank?
      next if imprint.job.order.blank?
      order = imprint.job.order
      job = imprint.job

      if job.name.include?(order.name) && !order.name.blank?
        job.update_attribute(:name, job.name.gsub(order.name, ''))
        puts "    JOB: #{job.name}\t\t #{order.name}"
      end

      if imprint.name.include?(job.name) && !job.name.blank?
        imprint.update_attribute(:name, imprint.name.gsub(job.name, ''))
        puts "IMPRINT: #{imprint.name}\t\t #{job.name}"
      end

    end
  end

  task unschedule_canceled: :environment do
    Imprint.where(state: 'canceled').where.not(scheduled_at: nil).update_all scheduled_at: nil
  end
end
