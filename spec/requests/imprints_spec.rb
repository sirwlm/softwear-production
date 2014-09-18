require 'spec_helper'

RSpec.describe "Imprints", :type => :request do
  describe "GET /imprints" do
    it "works! (now write some real specs)" do
      get imprints_path
      expect(response.status).to be(200)
    end
  end
end
