require 'spec_helper'

describe Schedulable do
  describe '::all_unscheduled' do
    context 'when there are a couple schedulable classes' do
      let!(:schedulable_class_1) { double('SomethingSchedulable', unscheduled: ['one', 'two']) }
      let!(:schedulable_class_2) { double('AnotherthingSchedulable', unscheduled: ['three', 'four']) }

      before do
        allow(Schedulable).to receive(:schedulable_classes).and_return [schedulable_class_1, schedulable_class_2]
      end

      it 'merges the unscheduled entries of each schedulable class', story_737: true do
        expect(Schedulable.all_unscheduled).to eq ['one', 'two', 'three', 'four']
      end
    end
  end

  describe '#production_deadline', story_1025: true, production_deadline: true do
    let(:order) { create(:order, deadline: Date.today) }

    context 'when the schedulable object has an order with a shipment_train' do
      subject { double('SomethingSchedulable', order: order).tap{ |s| s.send(:extend, Schedulable) } }
      let!(:shipment_train) { create(:shipment_train, shipment_holder: order, time_in_transit: 2) }

      it "returns order's deadline minus that shipment train's time_in_transit" do
        expect(subject.production_deadline).to eq (Date.today - 2.days).to_time
      end
    end

    context 'when the schedulable object has a job with a shipment_train' do
      subject { double('SomethingSchedulable', job: job).tap{ |s| s.send(:extend, Schedulable) } }
      let(:job) { create(:job, order: order) }
      let!(:order_shipment_train) { create(:shipment_train, shipment_holder: order, time_in_transit: 2) }
      let!(:shipment_train) { create(:shipment_train, shipment_holder: job, time_in_transit: 1) }

      it "returns the job's order deadline minus its shipment train time_in_transit" do
        expect(subject.production_deadline).to eq (Date.today - 1.day).to_time
      end
    end

    context 'when the schedulable object has a job with no shipment_train' do
      subject { double('SomethingSchedulable', job: job).tap{ |s| s.send(:extend, Schedulable) } }
      let(:job) { create(:job, order: order) }
      let!(:shipment_train) { create(:shipment_train, shipment_holder: order, time_in_transit: 3) }

      it "returns the job's order deadline minus the order's shipment train time_in_transit" do
        expect(subject.production_deadline).to eq (Date.today - 3.days).to_time
      end
    end

    context 'when the schedulable object has an order and its own shipment train' do
      subject { double('SomethingSchedulable', order: order, shipment_train: my_shipment_train).tap{ |s| s.send(:extend, Schedulable) } }
      let!(:order_shipment_train) { create(:shipment_train, shipment_holder: order, time_in_transit: 3) }
      let!(:my_shipment_train) { create(:shipment_train, time_in_transit: 2) }

      it "returns the order's deadline minus the shipment train's time_in_transit" do
        expect(subject.production_deadline).to eq (Date.today - 2.days).to_time
      end
    end

    context 'when the schedulable object has its own deadline and shipment train' do
      subject { double('SomethingSchedulable', deadline: Date.today.to_time, shipment_train: my_shipment_train).tap{ |s| s.send(:extend, Schedulable) } }
      let!(:my_shipment_train) { create(:shipment_train, time_in_transit: 2) }

      it "returns deadline - shipment train time in transit" do
        expect(subject.production_deadline).to eq (Date.today - 2.days).to_time
      end
    end
  end
end
