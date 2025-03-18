# frozen_string_literal: true

# The invited user who visited the url will see this page.
class InvitationsController < ApplicationController
  def create
    @parent_survey_response = SurveyResponse.find_by!(id: params[:parent_survey_response_id])
    @invitation = Invitation.create!(parent_response: @parent_survey_response, last_sent: Time.now, visited: false)

    render json: {
      message: "Invitation link created: #{invitation_url(@invitation.token)}",
      invitation_url: invitation_url(@invitation.token)
    }
  end

  def show
    @invitation = Invitation.find_by(token: params[:token])

    if @invitation.nil?
      redirect_to not_found_invitations_path
    else
      @invitation.update(visited: true) unless @invitation.visited

      if session[:userinfo].present?
        user_id = session[:userinfo]['sub']
        user_profile = SurveyProfile.find_by(user_id:)

        claim_invitation(user_profile) if user_profile
      end

      session[:invitation] = { from: @invitation.id }
    end
  end

  def not_found
    render :not_found
  end

  private

  def claim_invitation(user_profile)
    sharecode_from_invitation = @invitation.parent_response.share_code
  
    @new_response_to_fill = SurveyResponse.create!(
      profile: user_profile,
      share_code: sharecode_from_invitation
    )
  
    # ✅ Check if the user has already claimed this invitation
    existing_claim = InvitationClaim.find_by(invitation: @invitation, survey_profile: user_profile)
  
    unless existing_claim
      InvitationClaim.create!(
        invitation: @invitation,
        survey_profile: user_profile,
        survey_response: @new_response_to_fill
      )
    else
      Rails.logger.info "User #{user_profile.id} has already claimed invitation #{@invitation.id}"
    end
  end    
end  
