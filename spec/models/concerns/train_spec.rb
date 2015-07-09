require 'spec_helper'

class TestObject
  include ActiveModel::Model
  include Train

  attr_accessor :state

  train :state, initial: :first do
    event :normal_success do
      transition :first => :success
    end
    event :normal_failure do
      transition all => :failure
    end

    success_event :won do
      transition :first => :success
    end
    success_event :now_were_here do
      transition :failure => :success
    end
    failure_event :messed_up do
      transition :first => :failure
    end

    event :approve, params: { user_id: [1, 2, 3] } do
      transition :first => :approved
    end
    event :broadcast, public_activity: { message: :string } do
      transition :first => :success
    end
  end
end

describe Train do
  describe 'a model including `Train`', story_735: true do
    subject { TestObject.new(state: :first) }
    let(:state_machine) { StateMachines::Machine.find_or_create(TestObject, :state) }

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
          expect(state_machine.event_params[:approve]).to eq({ user_id: [1, 2, 3] })
        end
      end

      describe 'public_activity: {  }' do
        it "populates the state machine's event_public_activity[<event name>]" do
          expect(state_machine.event_public_activity[:broadcast]).to eq({ message: :string })
        end
      end
    end
  end
end
