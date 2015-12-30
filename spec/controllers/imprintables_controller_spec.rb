require 'spec_helper'

describe ImprintablesController do
  include_context "signed_in_as_user"

  describe "GET #index" do
    context "dashboard search" do
      it "searches text properly" do
        get :index, q: { text: "whatever was just typed" }
        expect(Sunspot.session).to be_a_search_for(ImprintableTrain)
        expect(Sunspot.session).to have_search_params(:fulltext, 'whatever was just typed')
      end

      it "searches state properly" do
        get :index, q: { state: "partially ordered" }
        expect(Sunspot.session).to be_a_search_for(ImprintableTrain)
        expect(Sunspot.session).to have_search_params(:with, :state, 'partially ordered')
      end
      
      it "searches expected arrival properly" do
        time = Time.now

        get :index, q: { expected_arrival_date: time }
        expect(Sunspot.session).to be_a_search_for(ImprintableTrain)
        expect(Sunspot.session).to have_search_params(:with, :expected_arrival_date, time.to_date)
      end

      context 'with imprintable trains present' do
        let(:scheduled_one_day_ago) { create(:print, scheduled_at: 1.day.ago) }
        let(:scheduled_two_days_ago) { create(:print, scheduled_at: 2.days.ago) }
        let(:train) { create(:imprintable_train) }
        let(:other_train) { create(:imprintable_train) }

        before do
          allow(ImprintableTrain).to receive(:search).and_return double('results', results: [train, other_train])
          allow(train).to receive(:imprints).and_return [scheduled_two_days_ago, scheduled_one_day_ago]
          allow(other_train).to receive(:imprints).and_return [scheduled_two_days_ago]
          allow(train.imprints).to receive(:pluck) { |a| train.imprints.map(&a) }
          allow(other_train.imprints).to receive(:pluck) { |a| other_train.imprints.map(&a) }
        end

        it 'can filter on imprints scheduled_at date' do
          get :index, q: { scheduled_at: 1.day.ago }
          expect(assigns[:imprintable_trains]).to eq [train]
        end
      end
    end
  end
end
