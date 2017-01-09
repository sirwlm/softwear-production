FactoryGirl.define do
  factory :digitization_train do
    order { |t| t.association(:order_with_emb_print) }
  end 
end
