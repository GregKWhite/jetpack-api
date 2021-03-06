class ProjectsController < ApplicationController
  before_action :set_project, except: [:index, :create, :issue_backlog]

  def index
    render json: Project.all, status: :ok
  end

  def show
    render json: @project, include: included_relationships
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      render json: @project, status: :ok
    else
      render json: @project, status: :bad_request
    end
  end

  def update
    if @project.update(project_params)
      render json: @project, status: :ok
    else
      render json: @project.reload, status: :bad_request
    end
  end

  def destroy
    @project.destroy
    render nothing: true, status: :no_content
  end

  def issue_backlog
    project = Project.find(params[:project_id])
    render json: project.issue_backlog
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:id, :name)
  end

  def included_relationships
    {
      sprints: [:issues, stories: { issues: :assignee }]
    }
  end
end
