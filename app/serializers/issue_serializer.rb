class IssueSerializer < ApplicationSerializer
  attributes :id, :description, :project_id, :status, :order,
             :sprint_id, :story_id, :assignee_id, :points

  has_many :comments
  belongs_to :assignee
end
