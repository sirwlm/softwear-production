namespace :metrics do

  task :generate_for_imprints, [:days] => [:environment] do |t, args|
    Imprint.send(:subclasses).each do |imprint_class|
      next if MetricType.where(metric_type_class: imprint_class.name).count == 0
      imprints = imprint_class.where('completed_at > ?', Time.now - (args.days.to_i).days)
      puts "#{imprints.count} #{imprint_class} "
      imprints.each do |imprint|
        imprint.create_metrics
      end
    end
  end
end