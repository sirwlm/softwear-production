require 'spec_helper'

describe FbaLabelTrain, fba_label_train_spec: true do
  
  describe 'complete?' do
    context "state is 'labels_staged'" do 
      
      subject(:train) { build_stubbed(:fba_label_train, state: :labels_staged) }
      
      it 'returns true' do 
        expect(train.complete?).to be_truthy
      end
    end

    context 'otherwise' do 

      subject(:train) { build_stubbed(:fba_label_train) }
      
      it 'returns true' do 
        expect(train.complete?).to be_falsy
      end
    end

  end

end
