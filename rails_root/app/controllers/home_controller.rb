# frozen_string_literal: true

# Controller for the home page
class HomeController < ApplicationController
  helper_method :invite_token
  def index
    return if session[:userinfo].nil?

    redirect_to new_survey_profile_path if SurveyProfile.find_by(user_id: session[:userinfo]['sub']).nil?

    @survey_profile = SurveyProfile.find_by(user_id: session[:userinfo]['sub'])
    return if @survey_profile.nil?

    @survey_responses = fetch_survey_responses
    @invitations = fetch_invitations
  end

  private

  def fetch_survey_responses
    SurveyResponse.where(profile_id: @survey_profile.id)
                  .where.not(id: InvitationClaim.select(:survey_response_id).where.not(survey_profile_id: @survey_profile.id))
  end
  
  def fetch_invitations
    @survey_responses.map do |response|
      # Find the invitation that was originally created for this response
      invitation = Invitation.joins(:claims).find_by(invitation_claims: { survey_response_id: response.id })
      invitation ? fetch_invited_by(invitation) : 'N/A'
    end
  end
  
  def fetch_invited_by(invitation)
    # Get the response that originally created the invitation
    parent_response = SurveyResponse.find_by(id: invitation.parent_response_id)
  
    # Ensure the parent response has a valid profile
    if parent_response&.profile
      "#{parent_response.profile.first_name} #{parent_response.profile.last_name}"
    else
      "N/A"
    end
  end
  

  def invite_token(response)
    invitations = Invitation.joins(:claims).where(invitation_claims: { survey_response_id: response.id })
    return "N/A" if invitations.empty?
  
    invitations.map(&:token).join(", ") # Show all invite tokens
  end  
end
