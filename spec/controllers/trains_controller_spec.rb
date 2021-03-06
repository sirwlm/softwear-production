### NOTE All Train tests reference the object spec/support/test_train.rb ###

require 'spec_helper'

describe TrainsController, type: :controller do
  include_context 'signed_in_as_user'
  let(:other_user) { create(:user) }
  let(:object) do
    TestTrain.new(state: :first).tap do |t|
      allow(t).to receive(:create_activity)
      allow(t).to receive(:save).and_return true
      allow(t).to receive(:save!).and_return true
    end
  end

  before do
    allow(TestTrain).to receive(:find).with('1') { object }
  end

  describe 'POST #create', story_736: true do
    class TestObject
      include ActiveModel::Model
      attr_accessor :id
      attr_accessor :test_trains
    end
    let(:object_test_trains) { [] }
    let(:test_object) { TestObject.new(test_trains: object_test_trains, id: 1) }

    before do
      allow(TestObject).to receive(:find).with('1').and_return test_object
      allow(test_object).to receive(:save!)
      request.env["HTTP_REFERER"] = root_path
    end

    context 'given an object class, id, and train class' do
      it 'adds a new instance of the train class to the object' do
        expect(test_object.test_trains.size).to eq 0
        post :create, model_name: 'TestObject', id: 1, train_class: TestTrain
        expect(test_object.test_trains.size).to eq 1
      end
    end
  end

  describe 'PATCH #transition', story_735: true do
    context 'given a model name, id, and event' do
      before do
        patch :transition, model_name: 'test_train', id: 1, event: :won, format: :js
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

      it 'creates a public activity entry with public_activity and params' do
        expect(object).to have_received(:create_activity)
          .with(action: :transition, parameters: { event: 'won' }, owner: user)
      end
    end

    context 'passed model params' do
      context 'when the given event has those registered' do
        it 'assigns them to the object' do
          expect(object.winner_id).to be_blank
          patch :transition, model_name: 'test_train', id: 1, event: :won,
            test_train: { winner_id: 3 }, format: :js
          expect(object.winner_id.to_i).to eq 3
        end
      end

      context 'when the given event does not have them registered' do
        it 'does not assign anything' do
          expect(object.winner_id).to be_blank
          patch :transition, model_name: 'test_train', id: 1, event: :approve,
            test_train: { winner_id: 3 }, format: :js
          expect(object.winner_id).to be_blank
        end
      end
    end

    context 'when the given event has a public activity entry' do
      it 'calls create_activity with parameters: <config value>' do
        expect(object).to receive(:create_activity)
          .with(
            action: :transition,
            parameters: { event: 'broadcast', message: 'hey' },
            owner: user
          )
        patch :transition,
          model_name: 'test_train',
          id: 1,
          event: :broadcast,
          public_activity: { message: 'hey' },
          format: :js
      end

      it 'assigns owner to User.find params[:public_activity][:owner_id]' do
        expect(object).to receive(:create_activity)
          .with(
            action: :transition,
            parameters: { event: 'broadcast', message: 'hey' },
            owner: other_user
          )
        patch :transition,
          model_name: 'test_train',
          id: 1,
          event: :broadcast,
          public_activity: { message: 'hey', owner_id: other_user.id },
          format: :js
      end

      it 'calls create_activity with public_activity and params', story_94: true do
        expect(object).to receive(:create_activity)
          .with(
            action: :transition,
            parameters: { event: 'won', user_id: 2, winner_id: 3 },
            owner: anything
          )
        patch :transition,
          model_name: 'test_train',
          id: 1,
          event: :won,
          public_activity: { user_id: 2 },
          test_train: { winner_id: 3 },
          format: :js
      end

      context 'when there is a blacklisted param' do
        before do
          allow(TestTrain).to receive(:train_public_activity_blacklist).and_return [:winner_id]
        end

        it 'does not use it for public activity' do
          expect(object).to receive(:create_activity)
            .with(
              action: :transition,
              parameters: { event: 'won', user_id: 2 },
              owner: anything
            )
          patch :transition,
            model_name: 'test_train',
            id: 1,
            event: :won,
            public_activity: { user_id: 2 },
            test_train: { winner_id: 3 },
            format: :js
        end
      end

      it 'creates an autocomplete entry for any text field params', story_875: true do
        patch :transition,
          model_name: 'test_train',
          id: 1,
          event: :broadcast,
          public_activity: { message: 'hello there' },
          format: :js

        expect(TrainAutocomplete.where(field: 'TestTrain#message', value: 'hello there')).to exist
      end
    end
  end

  describe "DELETE #destroy_dangling", dangling: true do
    let!(:dangling_train) { Ar3Train.create!(order: create(:order)) }
    let!(:non_dangling_train) { Ar3Train.create!(order: create(:order)) }

    before(:each) do
      dangling_train.update_column :order_id, nil
    end

    context '!!params[:destroy_all]' do
      it 'destroys all trains that lack their dependent field' do
        expect(Ar3Train.where(id: dangling_train.id)).to exist
        expect(Ar3Train.where(id: non_dangling_train.id)).to exist

        delete :destroy_dangling, destroy_all: 'Destroy all'
        expect(response).to redirect_to dangling_trains_path

        expect(Ar3Train.where(id: dangling_train.id)).to_not exist
        expect(Ar3Train.where(id: non_dangling_train.id)).to exist
      end
    end
  end

  describe "DELETE #destroy", current: true do
    class TestObject
      include ActiveModel::Model
      attr_accessor :id
      attr_accessor :test_trains
    end
    let(:object_test_trains) { [ object ] }
    let(:test_object) { TestObject.new(test_trains: object_test_trains, id: 1) }

    before do
      allow(object).to receive(:order) { create(:order) }
      allow(object).to receive(:remove_from_test_object) { test_object.test_trains = [] }
    end

    context 'user is not an admin' do
      it 'redirects them to the root with a notice' do
        delete :destroy, model_name: 'test_train', id: 1
        expect(response).to redirect_to(root_path)
      end
    end

    context 'user is an admin' do

      before do
        allow_any_instance_of(User).to receive(:role?).with('admin') { true }
      end

      it 'destroys the train' do
        expect{
          delete :destroy, model_name: 'test_train', id: 1
        }.to change{ test_object.test_trains.size }.from(1).to(0)
      end

      it 'redirects them to the order' do
        delete :destroy, model_name: 'test_train', id: 1
        expect(response.status).to eq(302)
      end
    end
  end

end
