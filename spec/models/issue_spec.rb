# == Schema Information
#
# Table name: issues
#
#  id          :integer          not null, primary key
#  project_id  :integer          not null
#  sprint_id   :integer
#  story_id    :integer
#  assignee_id :integer
#  description :text
#  points      :integer          default("1"), not null
#  status      :string           default("todo")
#  order       :integer
#

require 'rails_helper'

describe Issue do
  let(:attributes) { {} }
  subject { FactoryGirl.build_stubbed(Issue, attributes) }

  describe 'validations' do
    context 'when an issue has no points' do
      let(:attributes) { { points: nil } }
      it { should be_invalid }
    end

    context "when an issue's points are < 1" do
      let(:attributes) { { points: 0 } }
      it { should be_invalid }
    end

    context 'when the points attribute is left blank' do
      let(:attributes) { {} }

      it 'should default to 1 point' do
        expect(subject.points).to eq 1
      end
    end
  end
end
