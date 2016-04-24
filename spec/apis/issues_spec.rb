require 'rails_helper'

RSpec.describe 'Issue Requests', :no_auth, type: :api do
  let(:user) { FactoryGirl.create(User) }

  describe 'GET /project/:project_id/issues' do
    context 'when there are no issues' do
      before do
        @project = FactoryGirl.create(:project)
      end

      it 'should return an empty array' do
        get project_issues_path(@project)
        expect(response_body_json).to eq []
      end
    end

    context 'when there are issues' do
      before do
        @issue = FactoryGirl.create(:issue)
      end

      it 'should return all issues' do
        get project_issues_path(@issue.project)
        expect(response_body_json.count).to eq Issue.all.count
      end
    end
  end

  describe 'POST /project/:project_id/issues' do
    context 'when the creation is successful' do
      let(:project) { FactoryGirl.create(Project) }
      let(:issue_params) { FactoryGirl.attributes_for(Issue, project: project) }

      it 'should return the issue' do
        post project_issues_path(project), issue: issue_params
        expect(response_body_json['id']).to be_present
        expect(response_body_json['attributes']['description']).to eq issue_params[:description]
      end
    end

    context 'when the creation is not successful' do
      let(:project) { FactoryGirl.create(Project) }
      let(:issue_params) do
        {
          format: :json,
          issue: { description: '', project_id: project.id, some_thing: 'yolo' }
        }
      end

      it 'should return a bad request status' do
        post project_issues_path(project), issue_params
        expect(response).to be_bad_request
      end
    end
  end

  describe 'GET /issues/:id' do
    context 'when the issue exists' do
      let(:issue) { FactoryGirl.create(Issue) }

      it 'should return the issue' do
        get issue_path(issue)
        expect(response_body_json['id']).to eq issue.id.to_s
      end
    end

    context 'when the issue does not exist' do
      it 'should return an empty string' do
        expect { get '/issues/-1' }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'PATCH /issues/:id' do
    context 'when the update is successful' do
      let(:issue) { FactoryGirl.create(Issue) }
      let(:issue_params) do
        FactoryGirl.attributes_for(Issue, project: issue.project, description: 'yolo')
      end

      it 'should return the updated issue' do
        patch issue_path(issue), issue: issue_params
        expect(response_body_json['attributes']['description']).to eq 'yolo'
      end
    end

    context 'when the update is not successful' do
      let(:issue) { FactoryGirl.create(Issue) }
      let(:issue_params) do
        FactoryGirl.attributes_for(Issue, description: '')
      end

      it 'should return a bad request status' do
        patch issue_path(issue), issue: issue_params
        expect(response).to be_bad_request
      end
    end
  end

  describe 'PATCH /issues/:id/assignee' do
    let(:user) { FactoryGirl.create(User, team: team) }
    let(:team) { FactoryGirl.create(Team) }
    let(:issue) { FactoryGirl.create(Issue) }

    before do
      allow_any_instance_of(IssuesController).to receive(:current_user) { user }
    end

    context 'when assigning an issue to a user' do
      let(:params) do
        {
          format: :json,
          user_id: user.id
        }
      end

      it 'should assign the issue to the user' do
        patch assignee_issue_path(issue), params
        expect(issue.reload.assignee).to eq user
      end

      context 'when the user does not exist' do
        let(:params) do
          {
            format: :json,
            user_id: -1
          }
        end

        it 'should have a bad request status' do
          patch assignee_issue_path(issue), params
          expect(response).to be_bad_request
        end
      end
    end

    context 'when unassigning an issue from a user' do
      let(:params) { { format: :json } }

      it 'should unassign the issue from the user' do
        patch assignee_issue_path(issue), params
      end
    end
  end

  describe 'PATCH /stories/:id/issues/order' do
    context 'when an array of issues are given' do
      let(:story) { FactoryGirl.create(Story) }
      let!(:issue1) { FactoryGirl.create(Issue, story: story, order: 1) }
      let!(:issue2) { FactoryGirl.create(Issue, story: story, order: 2) }

      let(:json_data) { { 'issue_order' => [issue2.id, issue1.id] }.to_json }

      it "should set the issues' order and return them in the order given" do
        patch(
          "/stories/#{story.id}/issues/order",
          json_data,
          'Content-Type' => 'application/json'
        )

        expect(response_body_json[0]['id']).to eq issue2.id.to_s
        expect(response_body_json[0]['attributes']['order']).to eq 0
        expect(response_body_json[1]['id']).to eq issue1.id.to_s
        expect(response_body_json[1]['attributes']['order']).to eq 1
      end
    end
  end
end
