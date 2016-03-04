require 'spec_helper'

describe 'shared/_top_nav.html.erb' do
  include_context 'devise_view_setup'
  let!(:admin) { create(:admin) }
  let!(:user) { create(:user) }

  before(:each) do
    assign(:machines, [])
    render 'shared/top_nav.html.erb', current_user: user
  end

  context 'when the current user is an admin' do
    before(:each) { render 'shared/top_nav.html.erb', current_user: admin }

    it 'contains admin links to manage users, machines, maintenences', story_116: true do
      expect(rendered).to have_css 'a[href="/machines"]'
      expect(rendered).to have_css 'a[href="/maintenances"]'
    end
  end

  it 'doesn\'t allow peons to mess with other people shit', story_116: true do
    expect(rendered).to_not have_css 'a[href="/machines"]'
  end
end
