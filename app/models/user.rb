# == Schema Information
#
# Table name: public.users
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  team_id             :integer
#  name                :string           not null
#  github_id           :integer          not null
#  token               :string
#  github_access_token :string
#  profile_picture_url :string
#

class User < ActiveRecord::Base
  belongs_to :team
  has_many :issues

  before_create :generate_token

  default_scope { order(name: :asc) }

  private

  def generate_token
    loop do
      token = SecureRandom.uuid
      break self.token = token unless User.exists?(token: token)
    end
  end
end
