require 'spec_helper'

describe Train do
  describe 'a model including `Train`', story_735: true do
    subject { TestTrain.new(state: :first) }
    let(:state_machine) { StateMachines::Machine.find_or_create(TestTrain, :state) }
    let(:record_with_test_trains) { double('Record with test_trains', test_trains: []) }
    let(:record_with_test_train) { double('Record with test_train', test_train: TestTrain.new) }
    let(:record_with_nil_test_train) { double('Record with nil test_train', test_train: nil) }

    let(:test_class) do
      Class.new do
        include Train

        train_type :test_type
      end
    end

    it 'can use `success_event` and `failure_event` in its state machine' do
      expect{subject}.to_not raise_error
    end

    it 'reacts fine to normal event transitions' do
      expect(subject.state.to_sym).to eq :first
      subject.normal_success
      expect(subject.state.to_sym).to eq :success
      subject.normal_failure
      expect(subject.state.to_sym).to eq :failure
    end

    specify '#state_events returns all relevant events, including success and failure' do
      remaining_events = [:normal_success, :normal_failure, :won, :messed_up, :approve, :broadcast] - subject.state_events
      expect(remaining_events).to be_empty
    end

    specify '#state_events(:success) returns relevant events defined with success_event' do
      expect(subject.state_events(:success)).to eq [:won]
    end

    specify '#state_events(:failure) returns relevant events defined with failure_event' do
      expect(subject.state_events(:failure)).to eq [:messed_up]
    end

    context 'event option' do
      describe 'params: {  }' do
        it "populates the state machine's event_params[<event name>]" do
          expect(state_machine.event_params[:won]).to eq({ winner_id: [1, 2, 3] })
        end
      end

      describe 'public_activity: {  }' do
        it "populates the state machine's event_public_activity[<event name>]" do
          expect(state_machine.event_public_activity[:broadcast]).to eq({ message: :text_field })
        end
      end
    end

    describe '::train_type' do
      context 'when Train.train_types has nothing in it' do
        let!(:train_types) { {} }
        before do
          allow(Train).to receive(:train_types).and_return train_types
        end

        it 'creates an entry and adds its class to it' do
          test_class
          expect(Train.train_types).to eq(test_type: [test_class])
        end

        it 'defines a convenience method <category>_trains' do
          test_class
          expect(Train.test_type_trains).to include test_class
        end
      end

      context 'when Train.train_types already contains the category' do
        let!(:train_types) { { test_type:  [] } }
        before do
          allow(Train).to receive(:train_types).and_return train_types
        end

        it 'adds its class to the category' do
          test_class
          expect(Train.train_types[:test_type]).to include test_class
        end
      end
    end

    describe '::available_trains_of_type', story_736: true do
      let!(:train_types) { { preproduction: [TestTrain] } }
      before do
        allow(Train).to receive(:train_types).and_return train_types
      end

      context 'passed a record that responds to #test_trains' do
        subject { Train.available_trains_of_type(:preproduction, record_with_test_trains) }

        it { is_expected.to include TestTrain }
      end

      context 'passed a record that responds to #test_train - which is not nil' do
        subject { Train.available_trains_of_type(:preproduction, record_with_test_train) }

        it { is_expected.to_not include TestTrain }
      end

      context 'passed a record that responds to #test_train - which is nil' do
        subject { Train.available_trains_of_type(:preproduction, record_with_nil_test_train) }

        it { is_expected.to include TestTrain }
      end
    end
  end
end