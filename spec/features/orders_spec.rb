require 'spec_helper'

feature 'Orders' do
  include_context 'logged_in_as_user'

  given!(:machine) { create(:machine) }

  scenario 'I can create a new order, with jobs and imprints', js: true, story_676: true do
    visit new_order_path
    fill_in 'Name', with: 'Test Order'
    click_link 'New Job'

    within '.order-jobs' do
      fill_in 'Name', with: 'A job'
      click_link 'New Imprint'
      within '.job-imprints' do
        fill_in 'Name', with: 'An imprint'
        fill_in 'Description', with: 'Here it is - the imprint'
        select machine.name, from: 'Machine'
        fill_in 'Estimated Time in Hours', with: 3
        fill_in 'Machine Print Count', with: 7
      end
    end
    click_button 'Create Order'
    sleep 1
    expect(page).to have_content 'Test Order'
    click_link "An Imprint"
    sleep 1
    expect(page).to have_content "An imprint"
  end

  scenario 'I can edit an existing order (add/remove jobs and imprints)', plz: true, js: true, story_676: true, current: true do
    job = Job.create(name: 'Test Job')
    job.imprints = [create(:imprint, name: 'The Imprint')]
    order = create(:order, jobs: [job])

    visit edit_order_path(order)

    within '.order-jobs' do
      fill_in 'Name', with: 'New Job Name'
      within '.job-imprints' do
        fill_in 'Name', with: 'An imprint'
        fill_in 'Description', with: 'Here it is - the imprint'
        select machine.name, from: 'Machine'
        fill_in 'Estimated Time in Hours', with: 3
        fill_in 'Machine Print Count', with: 7
      end
    end

    click_link 'New Job'

    within '.new-job' do
      fill_in 'Name', with: 'Actually New Job'
      click_link 'New Imprint'
      within '.job-imprints' do
        fill_in 'Name', with: 'An imprint'
        fill_in 'Description', with: 'Here it is - the imprint'
        select machine.name, from: 'Machine'
        fill_in 'Estimated Time in Hours', with: 3
        fill_in 'Machine Print Count', with: 7
      end
    end
    click_button 'Update Order'
    order.reload
    expect(order.jobs.size).to eq 2
    expect(order.jobs.first.name).to eq 'New Job Name'
    expect(order.jobs.last.name).to eq 'Actually New Job'
  end

  scenario 'I can remove a job from an order', js: true, story_676: true, current: true do
    job = Job.create(name: 'Test Job')
    job.imprints = [create(:imprint, name: 'The Imprint')]
    order = create(:order, jobs: [job, job])

    visit edit_order_path(order)

    within '.order-jobs' do
      click_link 'Remove Job'
    end

    click_button 'Update Order'

    order.reload
    expect(order.jobs.size).to eq 1
  end
end
