module CapybaraExt
  def scan_barcode(input_id, barcode)
    page.evaluate_script("document.activeElement.id") == input_id
    fill_in input_id, with: barcode
    find("##{input_id}").native.send_keys(:return)
  end

  def page!
    save_and_open_page
  end

  def click_icon(type)
    find(".fa-#{type}").click
  end

  def eventually_fill_in(field, options={})
    page.should have_css('#' + field)
    fill_in field, options
  end

  def within_row(num, &block)
    if RSpec.current_example.metadata[:js]
      within("table.index tbody tr:nth-child(#{num})", &block)
    else
      within(:xpath, all('table.index tbody tr')[num-1].path, &block)
    end
  end

  def column_text(num)
    if RSpec.current_example.metadata[:js]
      find("td:nth-child(#{num})").text
    else
      all('td')[num-1].text
    end
  end

  def find_label_by_text(text)
    label = find_label(text)
    counter = 0

    # Because JavaScript testing is prone to errors...
    while label.nil? && counter < 10
      sleep(1)
      counter += 1
      label = find_label(text)
    end

    if label.nil?
      raise "Could not find label by text #{text}"
    end

    label
  end

  def find_label(text)
    first(:xpath, "//label[text()[contains(.,'#{text}')]]")
  end
end

Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = true
end

RSpec::Matchers.define :have_meta do |name, expected|
  match do |_actual|
    has_css?("meta[name='#{name}'][content='#{expected}']", visible: false)
  end

  failure_message do |actual|
    actual = first("meta[name='#{name}']")
    if actual
      "expected that meta #{name} would have content='#{expected}' but was '#{actual[:content]}'"
    else
      "expected that meta #{name} would exist with content='#{expected}'"
    end
  end
end

RSpec::Matchers.define :have_title do |expected|
  match do |_actual|
    has_css?("title", :text => expected, visible: false)
  end

  failure_message do |actual|
    actual = first('title')
    if actual
      "expected that title would have been '#{expected}' but was '#{actual.text}'"
    else
      "expected that title would exist with '#{expected}'"
    end
  end
end

RSpec.configure do |c|
  c.include CapybaraExt
end
