require 'spec_helper'

describe 'shared/_train_transitions.html.erb', story_735: true, type: :view do
  def do_render(locals = {})
    render partial: 'shared/train_transitions', locals: locals
  end

  let(:object_first) { TestTrain.new(state: :first) }
  let(:object_success) { TestTrain.new(state: :success) }
  let(:object_failure) { TestTrain.new(state: :failure) }

  it 'renders an event block for each category' do
    do_render object: object_first
    expect(rendered).to have_css '.train-events', count: 2
    expect(rendered).to have_css '.train-events-success'
    expect(rendered).to have_css '.train-events-failure'
  end

  it 'displays the name of each category' do
    do_render object: object_first
    expect(rendered).to have_css 'h3', text: 'Success', count: 1
    expect(rendered).to have_css 'h3', text: 'Failure', count: 1
  end

  it 'renders a button for each event with a class for its category' do
    do_render object: object_first
    expect(rendered).to have_css '.btn.btn-success', count: 1
    expect(rendered).to have_css '.btn.btn-failure', count: 1
  end

  context 'when there are no events in a category' do
    it 'displays "No actions available"' do
      do_render object: object_success
      expect(rendered).to have_css '.alert.alert-info', text: 'No actions available'
    end
  end

  context 'with fields that have params' do
    it 'renders text fields for params of the value :string' do
      do_render object: object_success
      expect(rendered).to have_css 'input[name="test_train[reason]"]'
      expect(rendered).to have_css 'input[name="test_train[reason]"][type=text]'
      expect(rendered).to have_css 'input[name="test_train[reason]"].event-text-field'
      expect(rendered).to have_css 'input[name="test_train[reason]"].text-field-failure'
    end

    it 'renders select boxes for params with array values' do
      do_render object: object_first
      expect(rendered).to have_css 'select[name="test_train[winner_id]"]'
      expect(rendered).to have_css 'select[name="test_train[winner_id]"].event-select-field'
      expect(rendered).to have_css 'select[name="test_train[winner_id]"].select-field-success'
    end
  end

  context 'with fields that have public_activity' do
    it 'renders text fields for params of the value :string' do
      do_render object: object_failure
      expect(rendered).to have_css 'input[name="public_activity[message]"]'
      expect(rendered).to have_css 'input[name="public_activity[message]"][type=text]'
      expect(rendered).to have_css 'input[name="public_activity[message]"].event-text-field'
      expect(rendered).to have_css 'input[name="public_activity[message]"].text-field-success'
    end

    it 'renders select boxes for params with array values' do
      do_render object: object_first
      expect(rendered).to have_css 'select[name="public_activity[user_id]"]'
      expect(rendered).to have_css 'select[name="public_activity[user_id]"].event-select-field'
      expect(rendered).to have_css 'select[name="public_activity[user_id]"].select-field-success'
    end
  end
end
