require 'spec_helper'

describe Metric, type: :model do

  context 'with a ScreenPrint with activities and, a MetricType that counts them' do
    let!(:screen_print) { create(:screen_print, completed_at: Time.now) }
    let!(:metric_type) { create(:metric_type_screen_print_start_count) }

    before do
      2.times do
        screen_print.activities << PublicActivity::Activity.new({
                                                  key: 'screen_print.transition',
                                                  parameters: {
                                                    'event' => 'print_started'
                                                  }
                                                })
      end
    end

    describe 'Metric.create_by_metric_type_and_object(metric_type, object)' do
      it 'creates a metric that counts the activities that apply' do
        Metric.create_by_metric_type_and_object(metric_type, screen_print)
        screen_print.reload
        expect(screen_print.metrics.count).to eq(1)
        expect(screen_print.metrics.first.value).to eq(2)
      end
    end
  end

  context 'with a ScreenPrint with one print_start and one print_end activity as well as a MetricType that counts them' do
    let!(:screen_print) { create(:screen_print, completed_at: Time.now) }
    let!(:metric_type) { create(:metric_type_screen_print_print_time) }

    before do
      now = Time.now
      screen_print.activities << PublicActivity::Activity.new({
                                                                key: 'screen_print.transition',
                                                                parameters: {
                                                                    'event' => 'print_started'
                                                                },
                                                                created_at: now - 30.minutes
                                                              })

      screen_print.activities << PublicActivity::Activity.new({
                                                                key: 'screen_print.transition',
                                                                parameters: {
                                                                  'event' => 'print_complete'
                                                                },
                                                                created_at: (now)
                                                              })
    end

    describe 'Metric.create_by_metric_type_and_object(metric_type, object)' do

      it 'creates a metric that measures the time between activities that apply' do
        Metric.create_by_metric_type_and_object(metric_type, screen_print)
        screen_print.reload
        expect(screen_print.metrics.count).to eq(1)
        expect(screen_print.metrics.first.value).to eq(30*60)
      end
    end
  end

  context 'with a ScreenPrint with multiple print_start and multiple print_end activity as well as a MetricType that counts them' do
    let!(:screen_print) { create(:screen_print, completed_at: Time.now) }
    let!(:metric_type) { create(:metric_type_screen_print_print_time) }

    before do
      now = Time.now
      screen_print.activities << PublicActivity::Activity.new({
                                                                key: 'screen_print.transition',
                                                                parameters: {
                                                                  'event' => 'print_started'
                                                                },
                                                                created_at: now - 30.minutes
                                                              })

      screen_print.activities << PublicActivity::Activity.new({
                                                                key: 'screen_print.transition',
                                                                parameters: {
                                                                  'event' => 'print_complete'
                                                                },
                                                                created_at: (now)
                                                              })
      screen_print.activities << PublicActivity::Activity.new({
                                                                key: 'screen_print.transition',
                                                                parameters: {
                                                                  'event' => 'print_started'
                                                                },
                                                                created_at: now - 60.minutes
                                                              })

      screen_print.activities << PublicActivity::Activity.new({
                                                                key: 'screen_print.transition',
                                                                parameters: {
                                                                  'event' => 'print_complete'
                                                                },
                                                                created_at: (now - 45.minutes)
                                                              })
    end

    describe 'Metric.create_by_metric_type_and_object(metric_type, object)' do
      it 'creates multiple metrics that each measures the time between activities that apply using the nearest value in each timeframe' do
        Metric.create_by_metric_type_and_object(metric_type, screen_print)
        screen_print.reload
        expect(screen_print.metrics.count).to eq(2)
        expect(screen_print.metrics.map(&:value)).to eq([30*60, 15*60])
      end
    end
  end
end
