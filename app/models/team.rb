# == Schema Information
#
# Table name: public.teams
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  projects_id :integer
#

class Team < ActiveRecord::Base
  after_create :create_schema
  after_destroy :drop_schema

  has_many :projects

  delegate :schema_name, :switch, :create_schema, :drop_schema, to: :schema_manager

  has_many :users

  def self.current
    Apartment::Tenant.current
  end

  private

  def schema_manager
    SchemaManager.new(self)
  end
end
