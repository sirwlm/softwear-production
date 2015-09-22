namespace :orders do

  task :complete_old, [:date] => :environment do |t, args|
    args.with_defaults(date: '2015-08-01')
    date = args.date
    
    orders = Order.search do
        with :complete, false
        with(:deadline).less_than(date) 
        order_by :deadline, :asc
        paginate page: 1, per_page: Order.count
    end
    .results

    puts orders.count
    user = User.find_by(email: 'ricky@annarbortees.com')

    orders.each do |o|
      # close order preproduction trains
      o.fba_label_train.state.update_attribute(:state, o.fba_label_train.train_machine.complete_state) unless o.fba_label_train.blank?
      
      # close order postproduction trains
      o.fba_bagging_train.update_attribute(:state, o.fba_bagging_train.train_machine.complete_state) unless o.fba_bagging_train.blank?
      o.shipment_train.update_attribute(:state, o.shipment_train.train_machine.complete_state) unless o.shipment_train.blank?
      o.store_delivery_train.update_attribute(:state, o.store_delivery_train.train_machine.complete_state) unless o.store_delivery_train.blank?
      o.local_delivery_train.update_attribute(:state, o.local_delivery_train.train_machine.complete_state) unless o.local_delivery_train.blank?
      o.stage_for_pickup_train.update_attribute(:state, o.stage_for_pickup_train.train_machine.complete_state) unless o.stage_for_pickup_train.blank?
    
      o.jobs.each do |j|
        j.imprintable_train.update_attribute(:state, j.imprintable_train.train_machine.complete_state) unless j.imprintable_train.blank?
        j.preproduction_notes_train.update_attribute(:state, j.preproduction_notes_train.train_machine.complete_state) unless j.preproduction_notes_train.blank?
        j.custom_ink_color_trains.each do |t|
          t.update_attribute(:state, t.train_machine.complete_state)
        end

        j.imprints.each do |i|
          if !i.completed? || i.state != i.train_machine.complete_state
            puts "Updating #{i.id} with state #{i.train_machine.complete_state}"
            i.update_column(:state, i.train_machine.complete_state)
            i.update_attribute(:completed_by_id, user.id)
            i.update_attribute(:completed_at, i.scheduled_at + i.estimated_time.hours)
          end
        end
        
        o.index
      end 
    end
  end

end
