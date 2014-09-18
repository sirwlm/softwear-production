require 'spec_helper'

RSpec.describe "Machines", :type => :request do
  describe "GET /machines" do
    it "works! (now write some real specs)" do
      get machines_path
      expect(response.status).to be(200)
    end
  end
end
