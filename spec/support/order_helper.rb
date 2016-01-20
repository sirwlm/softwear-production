module OrderUtils
  def create_order(order)
    visit new_order_path
    fill_in 'Name', with: order[:name]
    order[:jobs].each do |job|
    click_link 'New Job'
      within '.order-jobs' do
        fill_in 'Name', with: job[:name]
        job[:imprints].each do |imprint|
          click_link 'New Imprint'
          within '.job-imprints' do
            fill_in 'Name', with: imprint[:name]
            fill_in 'Description', with: imprint[:description]
            select imprint[:machine], from: 'Machine'
            select imprint[:type], from: 'Type'
            fill_in 'Estimated Time in Hours', with: imprint[:estimated_time]
            fill_in 'Machine Print Count', with: imprint[:machine_print_count]
          end
        end
      end
    end
    click_button 'Create Order'
    sleep 1.5
  end

  def success_transition(trans)
    within('.train-category-success') do
     click_button trans.to_s.humanize
    end
    sleep(1)
  end

  def delay_transition(trans)
    within('.train-category-delay') do
     click_button trans.to_s.humanize
    end
    sleep(1)
  end

  def failure_transition(trans)
    within('.train-category-failure') do
      click_button trans.to_s.humanize
    end
    sleep(1)
  end

  def sign_off_transition(trans, user)
    within('.train-category-success') do
      # select user.full_name, from: ''
      click_button trans.to_s.humanize
    end
  end

  def last(*args)
    all(*args).last
  end

  def select_from_select2(*args)
    if args.last.is_a?(Hash)
      options = args.pop
    else
      options = {}
    end
    finder = method(options[:finder] || :find)

    args.each do |arg|
      finder.call('.select2-container').click
      find('.select2-result', text: arg).click
    end
  end
end

RSpec.configure do |c|
  c.include OrderUtils
end
