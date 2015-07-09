require 'spec_helper'

describe 'shared/_train_transitions.html.erb', story_735: true, type: :view do
  def do_render(locals = {})
    render partial: 'shared/train_transitions', locals: locals
  end

  let(:object_first) { TestTrain.new(state: :first) }
  let(:object_success) { TestTrain.new(state: :success) }

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
end
