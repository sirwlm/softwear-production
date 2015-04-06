require 'spec_helper'

describe 'imprints/_search.html.erb' do
  it 'has search fields for text, scheduled_start_at_after, scheduled_start_at_before, and complete' do
    render 'imprints/search'
    expect(rendered).to have_selector("input[name='q[text]']")
    expect(rendered).to have_selector("input[name='q[scheduled_start_at_after]']")
    expect(rendered).to have_selector("input[name='q[scheduled_start_at_before]']")
    expect(rendered).to have_selector("select[name='q[complete]']")
  end
end
