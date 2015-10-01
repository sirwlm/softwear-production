require 'spec_helper'

describe ImprintableTrain, story_94: true do
  let(:job) { create(:job) }
  let(:imprintable_train) { create(:imprintable_train, job_id: job.id) }

  context 'when state is "imprintables_changed"' do
    describe '#resolved_changes' do
      context 'with solution=need_to_order' do
        it 'sets state to "ready_to_order"' do
          imprintable_train.update_attributes!(
            state:    :imprintable_changed,
            solution: :need_to_order
          )
          imprintable_train.resolved_changes
          expect(imprintable_train.reload.state).to eq 'ready_to_order'
        end
      end
    end
  end
end
