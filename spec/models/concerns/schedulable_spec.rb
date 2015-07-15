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
end
