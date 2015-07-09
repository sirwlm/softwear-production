require 'spec_helper'

describe TrainHelper, story_735: true do
  describe '#event_button' do
    it 'renders a form with a hidden input for the given event and submit button'

    context 'passed an event with params' do
      context 'with an array value' do
        it 'renders a select box with the given values as options'
      end

      context 'with a value of :string' do
        it 'renders a text box'
      end
    end
  end
end
