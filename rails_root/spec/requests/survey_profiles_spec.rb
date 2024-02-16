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

RSpec.describe '/survey_profiles', type: :request do
  # This should return the minimal set of attributes required to create a valid
  # SurveyProfile. As you add validations to SurveyProfile, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    # skip('Add a hash of attributes valid for your model')

    {
      user_id: 1,
      first_name: 'John',
      last_name: 'Doe',
      campus_name: 'Campus',
      district_name: 'District'
    }
  end

  let(:invalid_attributes) do
    # if any field is nil
    {
      user_id: 1,
      first_name: 'John',
      last_name: 'Doe',
      campus_name: 'Campus',
      district_name: nil
    }
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      SurveyProfile.create! valid_attributes
      get survey_profiles_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      survey_profile = SurveyProfile.create! valid_attributes
      get survey_profile_url(survey_profile)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_survey_profile_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      survey_profile = SurveyProfile.create! valid_attributes
      get edit_survey_profile_url(survey_profile)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new SurveyProfile' do
        expect do
          post survey_profiles_url, params: { survey_profile: valid_attributes }
        end.to change(SurveyProfile, :count).by(1)
      end

      it 'redirects to the created survey_profile' do
        post survey_profiles_url, params: { survey_profile: valid_attributes }
        expect(response).to redirect_to(survey_profile_url(SurveyProfile.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new SurveyProfile' do
        expect do
          post survey_profiles_url, params: { survey_profile: invalid_attributes }
        end.to change(SurveyProfile, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post survey_profiles_url, params: { survey_profile: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        # skip('Add a hash of attributes valid for your model')
        {
          user_id: 1,
          first_name: 'Johnson Micheal',
          last_name: 'Doe',
          campus_name: 'TAMU',
          district_name: 'College Station'
        }
      end

      it 'updates the requested survey_profile' do
        survey_profile = SurveyProfile.create! valid_attributes
        patch survey_profile_url(survey_profile), params: { survey_profile: new_attributes }
        survey_profile.reload
        # skip('Add assertions for updated state')
        expect(survey_profile.first_name).to eq('Johnson Micheal')
        expect(survey_profile.campus_name).to eq('TAMU')
        expect(survey_profile.district_name).to eq('College Station')
      end

      it 'redirects to the survey_profile' do
        survey_profile = SurveyProfile.create! valid_attributes
        patch survey_profile_url(survey_profile), params: { survey_profile: new_attributes }
        survey_profile.reload
        expect(response).to redirect_to(survey_profile_url(survey_profile))
      end
    end

    context 'with invalid parameters' do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        survey_profile = SurveyProfile.create! valid_attributes
        patch survey_profile_url(survey_profile), params: { survey_profile: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'tries to update non-existing profile' do
        survey_profile = SurveyProfile.create! valid_attributes
        patch survey_profile_url(survey_profile), params: { survey_profile: { user_id: 1000 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested survey_profile' do
      survey_profile = SurveyProfile.create! valid_attributes
      expect do
        delete survey_profile_url(survey_profile)
      end.to change(SurveyProfile, :count).by(-1)
    end

    it 'redirects to the survey_profiles list' do
      survey_profile = SurveyProfile.create! valid_attributes
      delete survey_profile_url(survey_profile)
      expect(response).to redirect_to(survey_profiles_url)
    end
  end
end
