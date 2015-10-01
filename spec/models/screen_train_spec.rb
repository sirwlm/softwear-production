require 'spec_helper'

describe ScreenTrain, type: :model do

  let(:screen_train) { create(:screen_train) }

  describe 'Relationships' do
    it { is_expected.to belong_to :order }
    it { is_expected.to have_many :assigned_screens }
    it { is_expected.to have_many(:screens).through(:assigned_screens) }
    it { is_expected.to have_many(:imprints) }
    it { is_expected.to have_many(:machines).through(:imprints) }
    it { is_expected.to have_many(:screen_requests) }
    it { is_expected.to have_many(:jobs).through(:imprints) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :order }
  end
  
  describe '#proof_request_data_complete?' do 
    context "an order is assigned, imprints are not empty, screen_requests aren't empty, "\
       "due_at is not blank, garment_material is not blank, garment_weight is not blank, "\
       "artwork_location is not blank, and print_type is not blank" do 
      
      before(:each) do
        screen_train.due_at = Time.now
        screen_train.garment_material = 'Something'
        screen_train.garment_weight = 'Something'
        screen_train.artwork_location = 'A Location'
        screen_train.print_type = 'Spot'
        screen_train.imprints << screen_train.order.imprints.first 
        screen_train.screen_requests << create(:screen_request, screen_train: screen_train)
      end

      it 'returns true' do 
        expect(screen_train.proof_request_data_complete?).to be_truthy      
      end
    end

    context "the above isn't met" do
     it 'returns false' do 
        expect(screen_train.proof_request_data_complete?).to be_falsy
      end
    end
  end

  describe '#screen_ink' do 
    before(:each) do 
      screen_train.screen_requests << build(:screen_request, ink: 'Red')
      screen_train.screen_requests << build(:screen_request, ink: 'White')
      screen_train.screen_requests << build(:screen_request, ink: 'White')
    end
    
    it 'returns an array of screen_request colors' do 
      expect(screen_train.screen_inks).to eq(['Red', 'White'])
    end 
  end

  describe '#all_screens_assigned?' do 
    before(:each) { screen_train.screen_requests << build(:screen_request) }
    
    context "the assigned_screens count == the screen_ink count" do 
    
      before(:each) do  
        assigned_screen = build(:assigned_screen)
        screen_request = build(:screen_request)
        screen_request.frame_type = assigned_screen.screen.frame_type
        screen_request.mesh_type = assigned_screen.screen.mesh_type
        screen_request.dimensions = assigned_screen.screen.dimensions
        assigned_screen.screen_request = screen_request
        screen_train.assigned_screens << assigned_screen
      end
      
      it 'returns true' do 
        expect(screen_train.all_screens_assigned?).to be_truthy
      end
    end
    
    context "the assigned_screens count < the screen_ink count" do 

      it 'returns false' do 
        expect(screen_train.all_screens_assigned?).to be_falsy    
      end
    end
  end

  describe '#fba?' do 

    context 'order.fba? == false' do 
      before(:each) { screen_train.order.fba = false }
      
      it 'returns false' do 
        expect(screen_train.fba?).to be_falsy
      end
    end
    
    context 'order.fba? == true' do 
      before(:each) { screen_train.order.fba = true }
      
      it 'returns true' do 
        expect(screen_train.fba?).to be_truthy
      end
    end
  end

end
