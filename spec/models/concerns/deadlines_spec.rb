require 'spec_helper'

describe Deadlines do
  describe '#production_deadline', story_1025: true, production_deadline: true do
    let(:order) { create(:order, deadline: Date.today) }

    context 'when the object has an order with a shipment_train' do
      subject { double('Something', order: order).tap{ |s| s.send(:extend, Schedulable) } }
      let!(:shipment_train) { create(:shipment_train, shipment_holder: order, time_in_transit: 2) }

      it "returns order's deadline minus that shipment train's time_in_transit" do
        expect(subject.production_deadline).to eq (Date.today - 2.days).to_time
      end
    end

    context 'when the object has a job with a shipment_train' do
      subject { double('Something', job: job).tap{ |s| s.send(:extend, Schedulable) } }
      let(:job) { create(:job, order: order) }
      let!(:order_shipment_train) { create(:shipment_train, shipment_holder: order, time_in_transit: 2) }
      let!(:shipment_train) { create(:shipment_train, shipment_holder: job, time_in_transit: 1) }

      it "returns the job's order deadline minus its shipment train time_in_transit" do
        expect(subject.production_deadline).to eq (Date.today - 1.day).to_time
      end
    end

    context 'when the object has a job with no shipment_train' do
      subject { double('Something', job: job).tap{ |s| s.send(:extend, Schedulable) } }
      let(:job) { create(:job, order: order) }
      let!(:shipment_train) { create(:shipment_train, shipment_holder: order, time_in_transit: 3) }

      it "returns the job's order deadline minus the order's shipment train time_in_transit" do
        expect(subject.production_deadline).to eq (Date.today - 3.days).to_time
      end
    end

    context 'when the object has an order and its own shipment train' do
      subject { double('Something', order: order, shipment_train: my_shipment_train).tap{ |s| s.send(:extend, Schedulable) } }
      let!(:order_shipment_train) { create(:shipment_train, shipment_holder: order, time_in_transit: 3) }
      let!(:my_shipment_train) { create(:shipment_train, time_in_transit: 2) }

      it "returns the order's deadline minus the shipment train's time_in_transit" do
        expect(subject.production_deadline).to eq (Date.today - 2.days).to_time
      end
    end

    context 'when the object has its own deadline and shipment train' do
      subject { double('Something', deadline: Date.today.to_time, shipment_train: my_shipment_train).tap{ |s| s.send(:extend, Schedulable) } }
      let!(:my_shipment_train) { create(:shipment_train, time_in_transit: 2) }

      it "returns deadline - shipment train time in transit" do
        expect(subject.production_deadline).to eq (Date.today - 2.days).to_time
      end
    end
  end
end
