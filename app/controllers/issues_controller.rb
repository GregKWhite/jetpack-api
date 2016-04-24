class IssuesController < ApplicationController
  before_action :set_issue, except: [:create, :index, :order]

  def index
    render json: issue_parent.issues, include: 'assignee'
  end

  def show
    render json: @issue, include: %w(comments assignee), status: :ok
  end

  def update
    if @issue.update(issue_params)
      render json: @issue, include: 'assignee'
    else
      render json: @issue, status: :bad_request
    end
  end

  def destroy
    @issue.destroy
    render nothing: true, status: :no_content
  end

  def create
    @issue = issue_parent.issues.new(issue_params)

    if @issue.save
      render json: @issue, include: 'assignee', status: :ok
    else
      render json: @issue, status: :bad_request
    end
  end

  def assignee
    if params[:user_id].present?
      API::IssueAssigner.assign!(current_user.team, @issue, user)
    else
      API::IssueAssigner.unassign!(@issue)
    end
    render json: @issue.reload, status: :ok
  rescue => e
    render json: { errors: e.message }, status: :bad_request
  end

  def order
    new_order = API::IssueOrderer.new(JSON.parse(request.body.read)['issue_order']).call
    render json: new_order, status: :ok
  end

  private

  def user
    User.find(params[:user_id])
  end

  def issue_parent
    project || sprint || story
  end

  def project
    Project.find(params[:project_id]) if params[:project_id]
  end

  def sprint
    Sprint.find(params[:sprint_id]) if params[:sprint_id]
  end

  def story
    Story.find(params[:story_id]) if params[:story_id]
  end

  def issue_params
    params.require(:issue).permit(*issue_fields)
  end

  def issue_fields
    [:id, :description, :status, :points, :order, :project_id, :sprint_id, :story_id].freeze
  end

  def set_issue
    @issue = Issue.find(params[:id])
  end
end
