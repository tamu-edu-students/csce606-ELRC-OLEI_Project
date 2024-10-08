# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

# rubocop:disable Metrics/BlockLength
RSpec.describe '/survey_questions', type: :request do
  # This should return the minimal set of attributes required to create a valid
  # SurveyQuestion. As you add validations to SurveyQuestion, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { text: 'What is your name?', section: 1 }
  end

  let(:invalid_attributes) do
    { text: '', section: 1 }
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      SurveyQuestion.create! valid_attributes
      get survey_questions_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      survey_question = SurveyQuestion.create! valid_attributes
      get survey_question_url(survey_question)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_survey_question_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      survey_question = SurveyQuestion.create! valid_attributes
      get edit_survey_question_url(survey_question)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new SurveyQuestion' do
        expect do
          post survey_questions_url, params: { survey_question: valid_attributes }
        end.to change(SurveyQuestion, :count).by(1)
      end

      it 'redirects to the created survey_question' do
        post survey_questions_url, params: { survey_question: valid_attributes }
        expect(response).to redirect_to(survey_question_url(SurveyQuestion.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new SurveyQuestion' do
        expect do
          post survey_questions_url, params: { survey_question: invalid_attributes }
        end.to change(SurveyQuestion, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post survey_questions_url, params: { survey_question: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        { text: 'What is your major?', section: 1 }
      end

      it 'updates the requested survey_question' do
        survey_question = SurveyQuestion.create! valid_attributes
        patch survey_question_url(survey_question), params: { survey_question: new_attributes }
        survey_question.reload
        expect(survey_question.text).to eq('What is your major?')
      end

      it 'redirects to the survey_question' do
        survey_question = SurveyQuestion.create! valid_attributes
        patch survey_question_url(survey_question), params: { survey_question: new_attributes }
        survey_question.reload
        expect(response).to redirect_to(survey_question_url(survey_question))
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        survey_question = SurveyQuestion.create! valid_attributes
        patch survey_question_url(survey_question), params: { survey_question: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested survey_question' do
      survey_question = SurveyQuestion.create! valid_attributes
      expect do
        delete survey_question_url(survey_question)
      end.to change(SurveyQuestion, :count).by(-1)
    end

    it 'redirects to the survey_questions list' do
      survey_question = SurveyQuestion.create! valid_attributes
      delete survey_question_url(survey_question)
      expect(response).to redirect_to(survey_questions_url)
    end
  end
end
# rubocop:enable Metrics/BlockLength
