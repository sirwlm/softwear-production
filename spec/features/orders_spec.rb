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
        select "Print", from: 'Type'
        fill_in 'Estimated Time in Hours', with: 3
        fill_in 'Machine Print Count', with: 7
      end
    end
    click_button 'Create Order'
    sleep 1
    expect(page).to have_content 'Test Order'
    within('.production_trains') do
      click_link "Show Full Details"
    end
    sleep 1
    expect(page).to have_content "An imprint"
  end

  scenario 'I can edit an existing order (add/remove jobs and imprints)', plz: true, 
    js: true, story_676: true do
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
        select "Print", from: 'Type'
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
        select "Print", from: 'Type'
        fill_in 'Estimated Time in Hours', with: 3
        fill_in 'Machine Print Count', with: 7
      end
    end
    click_button 'Update Order'
    sleep 2
    order.reload
    expect(order.jobs.size).to eq 2
    expect(order.jobs.first.name).to eq 'New Job Name'
    expect(order.jobs.last.name).to eq 'Actually New Job'
  end

  scenario 'I can remove a job from an order', js: true, story_676: true  do
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

  describe 'trains', js: true, trains: true do
    scenario 'I can advance the state of an FBA Bagging Train', story_737: true, retry: 3 do
      job = Job.create(name: 'Test Job')
      job.imprints = [create(:imprint, name: 'The Imprint')]
      order = create(:order, fba: true, jobs: [job, job])
      order.add_fba_bagging_train
      visit order_path(order)

      sleep 1

      within '#order-post-production .post_production_trains' do
        click_link 'Show Full Details'
      end

      sleep 1
      click_button 'Bagging started'
      sleep 1
      expect(page).to have_content 'Current State: Bagging In Progress'
      click_button 'Close'
      expect(page).to have_content 'State bagging in progress'
    end
  end

  describe 'for an existing order', js: true, story_869: true do
    given(:job) { create(:job) }
    given(:order) { create(:order, jobs: [job]) }

    context 'and there is a matching crm order' do
      given!(:crm_order) { create(:crm_order_with_proofs) }
      given(:proofs) { crm_order.proofs artwork_paths: [Rails.root.join('spec/fixtures/images/capybara1.JPG')] }

      background do
        order.softwear_crm_id = crm_order.id
        order.save!
      end

      scenario 'I can see the proofs from crm', story_864: true do
        visit order_path(order)

        expect(page).to have_content 'Status: Pending'
      end
    end

    scenario 'I can add an embroidery print' do
      visit edit_order_path(order)
      within '.order-jobs' do
        within '.job-imprints' do
          fill_in 'Name', with: 'An imprint'
          fill_in 'Description', with: 'Here it is - the imprint'
          select "Embroidery Print", from: 'Type'
        end
      end

      click_button 'Update Order'
      sleep 1

      expect(page).to have_content 'Here it is - the imprint'
      expect(page).to have_content 'Hooray! Order was successfully updated.'
    end

    scenario 'I can add a transfer print' do
      visit edit_order_path(order)
      within '.order-jobs' do
        within '.job-imprints' do
          fill_in 'Name', with: 'An imprint'
          fill_in 'Description', with: 'Here it is - the imprint'
          select "Transfer Print", from: 'Type'
        end
      end

      click_button 'Update Order'
      sleep 1

      expect(page).to have_content 'Here it is - the imprint'
      expect(page).to have_content 'Hooray! Order was successfully updated.'
    end

    scenario 'I can add an transfer making print' do
      visit edit_order_path(order)
      within '.order-jobs' do
        within '.job-imprints' do
          fill_in 'Name', with: 'An imprint'
          fill_in 'Description', with: 'Here it is - the imprint'
          select "Transfer Making Print", from: 'Type'
        end
      end

      click_button 'Update Order'
      sleep 1

      expect(page).to have_content 'Here it is - the imprint'
      expect(page).to have_content 'Hooray! Order was successfully updated.'
    end

    scenario 'I can add a button making print' do
      visit edit_order_path(order)
      within '.order-jobs' do
        within '.job-imprints' do
          fill_in 'Name', with: 'An imprint'
          fill_in 'Description', with: 'Here it is - the imprint'
          select "Button Making Print", from: 'Type'
        end
      end

      click_button 'Update Order'
      sleep 1

      expect(page).to have_content 'Here it is - the imprint'
      expect(page).to have_content 'Hooray! Order was successfully updated.'
    end

    scenario 'I can add a digital print to an order' do
      visit edit_order_path(order)
      within '.order-jobs' do
        within '.job-imprints' do
          fill_in 'Name', with: 'An imprint'
          fill_in 'Description', with: 'Here it is - the imprint'
          select "Digital Print", from: 'Type'
        end
      end

      click_button 'Update Order'
      sleep 1

      expect(page).to have_content 'Here it is - the imprint'
      expect(page).to have_content 'Hooray! Order was successfully updated.'
    end
  end

  describe 'imprint groups', js: true, story_768: true  do
    given(:imprint_group) { create(:imprint_group, order_id: order.id) }
    given(:imprint_1) { job_1.imprints.first.tap { |i| i.update_attributes name: 'Imprint 1' } }
    given(:imprint_2) { job_2.imprints.first { |i| i.update_attributes name: 'Imprint 2' } }
    given(:job_1) { create(:job) }
    given(:job_2) { create(:job) }
    given(:order) { create(:order, has_imprint_groups: true, jobs: [job_1, job_2]) }

    scenario 'I can specify that an order has imprint groups during creation' do
      visit new_order_path
      check 'Has imprint groups'
      fill_in 'Name', with: 'Test Order'
      click_link 'New Job'

      within '.order-jobs' do
        fill_in 'Name', with: 'A job'
        click_link 'New Imprint'
        within '.job-imprints' do
          fill_in 'Name', with: 'An imprint'
          fill_in 'Description', with: 'Here it is - the imprint'
          select machine.name, from: 'Machine'
          select "Print", from: 'Type'
          fill_in 'Estimated Time in Hours', with: 3
          fill_in 'Machine Print Count', with: 7
        end
      end
      click_button 'Create Order'
      sleep 1

      expect(page).to have_content 'Imprint Groups'
      expect(Order.where(has_imprint_groups: true)).to exist
    end

    scenario 'I can add an imprint group to an order' do
      visit order_path(order)

      find('.add-imprint-group').click
      sleep 1
      within '.imprint-groups' do
        expect(page).to have_content /Group #\d/
        expect(page).to have_content 'Drop Imprints Below'
        expect(ImprintGroup.where(order_id: order.id)).to exist
      end
    end

    scenario 'I can drag an imprint onto an imprint group' do
      imprint_1; imprint_2; imprint_group

      visit order_path(order)

      find("#imprint-#{imprint_1.id} .draggable-imprint")
        .drag_to(find("#imprint-group-#{imprint_group.id} .imprint-group-drop-zone"))

      sleep 1
      expect(imprint_1.reload.imprint_group_id).to eq imprint_group.id

      within '.imprint-group' do
        expect(page).to have_content 'Imprint 1'
      end
      within "#job-#{job_1.id}" do
        expect(page).to have_content "(Group ##{imprint_group.id}) Imprint 1"
      end
    end

    scenario 'I can remove an imprint from an imprint group' do
      imprint_1; imprint_2; imprint_group
      imprint_1.update_attributes! imprint_group_id: imprint_group.id

      visit order_path(order)

      within '.imprint-group' do
        find('.remove-imprint-from-group').click
        expect(page).to_not have_content 'Imprint 1'
      end
      sleep 1

      within "#job-#{job_1.id}" do
        expect(page).to have_content "Imprint 1"
        expect(page).to_not have_content "(Group ##{imprint_group.id}) Imprint 1"
      end

      expect(imprint_1.reload.imprint_group_id).to be_nil
    end

    scenario 'I can remove an imprint group, purging it of its imprints', current: true,  rm_imprint_group: true do
      imprint_1; imprint_2; imprint_group
      imprint_1.update_attributes! imprint_group_id: imprint_group.id

      visit order_path(order)

      within "#job-#{job_1.id}" do
        expect(page).to have_content "(Group ##{imprint_group.id}) Imprint 1"
      end

      find('.remove-imprint-group').click
      sleep 1

      within "#job-#{job_1.id}" do
        expect(page).to have_content "Imprint 1"
        expect(page).to_not have_content "(Group ##{imprint_group.id}) Imprint 1"
      end

      expect(page).to_not have_selector "#imprint-group-#{imprint_group.id}"
    end

    scenario 'I can edit an imprint group', edit_imprint_group: true, retry: 2 do
      imprint_1; imprint_2; imprint_group
      imprint_1.update_attributes! imprint_group_id: imprint_group.id

      visit order_path(order)

      within '.imprint-group' do
        find('.edit-imprint-group').click
      end

      select machine.name, from: 'Machine'
      fill_in 'Estimated Time in Hours', with: '5'

      click_button 'Update Imprint group'

      sleep 2

      expect(imprint_group.reload.machine_id).to eq machine.id
      expect(imprint_group.estimated_time).to eq 5

      expect(page).to have_content machine.name
    end
  end
end
