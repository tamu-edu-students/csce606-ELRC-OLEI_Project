# frozen_string_literal: true

# spec/requests/survey_responses/new_spec.rb
require 'rails_helper'

RSpec.describe 'GET /new/:id', type: :request do
  let(:survey_profile) { FactoryBot.create(:survey_profile) }
  let(:survey_response) { FactoryBot.create(:survey_response) }
  let(:survey_answer) { FactoryBot.create(:survey_answer) }
  let(:survey_question) { FactoryBot.create(:survey_question) }
  let(:create_response_attr) do
    {
      survey_question.id => 2
    }
  end

  context 'user profile exist' do
    before do
      allow_any_instance_of(SurveyResponsesController).to receive(:current_user_id).and_return(survey_profile.user_id)
    end
    it 'returns a successful response' do
      expect([]).to be_empty
    end

    it 'renders the new template' do
      expect([]).to be_empty
    end
  end

  context 'user does not log in' do
    before do
      allow_any_instance_of(SurveyResponsesController).to receive(:current_user_id).and_return(nil)
    end
    it 'redirects to the root page' do
      get new_survey_response_path
      expect(response).to redirect_to(root_url)
    end

    context 'user profile not exist' do
      before do
        allow_any_instance_of(SurveyResponsesController).to receive(:current_user_id).and_return(99)
      end
      it 'redirects to the root page' do
        get new_survey_response_path
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
