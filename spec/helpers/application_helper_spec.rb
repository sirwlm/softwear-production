require 'spec_helper'

describe ApplicationHelper, helper_spec: true do

  describe '#alert_class_from_flash_type' do
    it 'returns alert-danger if error' do
      expect(alert_class_from_flash_type('error')).to eq('alert-danger')
    end

    it 'returns alert-danger if alert' do
      expect(alert_class_from_flash_type('alert')).to eq('alert-danger')
    end

    it 'returns alert-success if notice' do
      expect(alert_class_from_flash_type('notice')).to eq('alert-success')
    end
  end

  describe '#alert_text_from_flash_type' do
    it 'returns error if error' do
      expect(alert_text_from_flash_type('error')).to eq('Error!')
    end

    it 'returns error if alert' do
      expect(alert_text_from_flash_type('alert')).to eq('Error!')
    end

    it 'returns hooray if notice' do
      expect(alert_text_from_flash_type('notice')).to eq('Hooray!')
    end
  end

  context 'with a specific time' do
    let!(:time) { DateTime.new(2014, 9, 25, 8, 37) }

    describe '#datetimepicker_format' do
      it 'returns a properly formatted datetime' do
        expect(datetimepicker_format(time)).to eq('09/25/2014 08:37 AM')
      end
    end

    describe '#fullcalendar_format' do
      it 'returns a properly formatted datetime' do
        expect(fullcalendar_format(time)).to eq('2014-09-25 08:37:00')
      end
    end
  end

  describe '#model_table_row_id', story_116: true do
    let! (:user) { create(:user) }

    it 'returns the model name underscored and with the record id at the end' do
      expect(model_table_row_id(user)).to eq("user_#{user.id}")
    end
  end

  describe '#human_boolean', story_116: true do
    it 'returns Yes when given a true value' do
      expect(human_boolean(true)).to eq('Yes')
    end
    it 'returns No when given a false value' do
      expect(human_boolean(false)).to eq('No')
    end
  end

  describe '#create_or_edit_text', story_116: true do
    context 'object is a new record' do
      it 'returns Create' do
        expect(create_or_edit_text(Order.new)).to eq('Create')
      end
    end

    context 'object is an existing record' do
      let! (:order) { create(:order) }

      it 'returns Update' do
        expect(create_or_edit_text(order)).to eq('Update')
      end
    end
  end
end
