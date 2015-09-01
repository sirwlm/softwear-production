require 'spec_helper'

describe FbaBaggingTrain, fba_bagging_spec: true do
  
  describe 'complete?' do
    context "state is 'bagged'" do 
      
      subject(:train) { build_stubbed(:fba_bagging_train, state: :bagged) }
      
      it 'returns true' do 
        expect(train.complete?).to be_truthy
      end
    end

    context 'otherwise' do 

      subject(:train) { build_stubbed(:fba_bagging_train) }
      
      it 'returns true' do 
        expect(train.complete?).to be_falsy
      end
    end

  end

end
