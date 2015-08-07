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
    end
  end
end
