require 'spec_helper'
require 'cancan/matchers'

describe Maintenance do
  let(:maintenance) { create(:maintenance, name: 'Test Maintenance') }

  describe '#display', story_111: true do
    subject { maintenance.display }

    context 'when completed' do
      before { allow(maintenance).to receive(:completed?).and_return true }

      it { is_expected.to eq "(COMPLETE) (MAINTENANCE) Test Maintenance" }
    end

    context 'when not completed' do
      before { allow(maintenance).to receive(:completed?).and_return false }

      it { is_expected.to eq "(MAINTENANCE) Test Maintenance" }
    end
  end

  describe 'colors', story_111: true do
    context 'when completed' do
      before { allow(maintenance).to receive(:completed?).and_return true }

      it 'has a white background with black text' do
        expect(maintenance.calendar_color).to eq 'white'
        expect(maintenance.text_color).to eq 'black'
      end
    end

    context 'when not completed' do
      before { allow(maintenance).to receive(:completed?).and_return false }

      it 'has a black background with white text' do
        expect(maintenance.calendar_color).to eq 'black'
        expect(maintenance.text_color).to eq 'white'
      end
    end
  end

  describe 'User' do
    describe "abilities" do
      subject(:ability) { Ability.new(user) }
      let(:user) { nil }

      context "when is an admin" do
        let(:user) { create(:admin) }

        it { should be_able_to(:manage, Maintenance.new) }
      end

      context "when is a user" do
        let(:user) { create(:user) }

        it { should_not be_able_to(:manage, Maintenance.new) }
        it { should be_able_to(:read, Maintenance.new) }
      end
    end
  end
end
