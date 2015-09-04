require 'spec_helper'

describe Print, print_spec: true do
  describe 'complete?' do
    context "state is 'complete'" do 
      subject(:print) { build_stubbed(:print, state: :complete) }
      
      it 'returns true' do 
        expect(print.complete?).to be_truthy
      end
    end

    context 'otherwise' do 
      subject(:print) { build_stubbed(:print) }
      
      it 'returns true' do 
        expect(print.complete?).to be_falsy
      end
    end
  end

end





