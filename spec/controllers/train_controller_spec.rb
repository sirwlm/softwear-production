require 'spec_helper'

describe TrainController, type: :controller do
  include_context 'signed_in_as_user'
  let(:object) { TestTrain.new(state: :first) }

  before do
    allow(TestTrain).to receive(:find).with('1').and_return object
    allow(object).to receive(:create_activity)
    allow(object).to receive(:save).and_return true
    allow(object).to receive(:save!).and_return true
  end

  describe 'PATCH #transition', story_735: true do
    context 'given a model name, id, and event' do
      before do
        patch :transition, model_name: 'test_train', id: 1, event: :won
      end

      it 'camelizes and constantizes model_name and finds the record by id' do
        expect(assigns(:object)).to eq object
      end

      it 'assigns event to params[:event]' do
        expect(assigns(:object)).to eq object
      end

      it 'fires the event' do
        expect(object.state).to eq 'success'
      end

      it 'creates a public activity entry' do
        expect(object).to have_received(:create_activity)
          .with(action: :transition, parameters: { event: :won }, owner: user)
      end
    end

    context 'passed model params' do
      context 'when the given event has those registered' do
        it 'assigns them to the object' do
          expect(object.winner_id).to be_blank
          patch :transition, model_name: 'test_train', id: 1, event: :won,
            test_train: { winner_id: 3 }
          expect(object.winner_id).to eq '3'
        end
      end

      context 'when the given event does not have them registered' do
        it 'does not assign anything' do
          expect(object.winner_id).to be_blank
          patch :transition, model_name: 'test_train', id: 1, event: :approve,
            test_train: { winner_id: 3 }
          expect(object.winner_id).to be_blank
        end
      end
    end

    context 'when the given event has a public activity entry' do
      it 'calls create_activity with parameters: <config value>' do
        expect(object).to receive(:create_activity)
          .with(
            action: :transition,
            parameters: { event: :broadcast, message: 'hey' },
            owner: user
          )
        patch :transition, model_name: 'test_train', id: 1, event: :broadcast, public_activity: { message: 'hey' }
      end
    end
  end
end
