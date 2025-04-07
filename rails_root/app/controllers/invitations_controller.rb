# frozen_string_literal: true

# The invited user who visited the url will see this page.
class InvitationsController < ApplicationController
  def create
    @parent_survey_response = SurveyResponse.find_by!(id: params[:parent_survey_response_id])
    @invitation = Invitation.create!(parent_response: @parent_survey_response, last_sent: Time.now, visited: false)

    render json: {
      message: "Invitation link created. Please save this link for you to share with others who will complete their perceptions of your Leadership.: #{invitation_url(@invitation.token)}",
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
        inviter_profile = @invitation.parent_response.profile
  
        if user_profile
          if user_profile.id == inviter_profile.id
            flash[:alert] = "You cannot respond to your own invitation."
            redirect_to root_path and return
          else
            claim_invitation(user_profile)
            session[:page_number] = 1
            session[:survey_id] = nil
          end
        end
      end
  
      session[:invitation] = { from: @invitation.id }
    end
  end
    

  def not_found
    render :not_found
  end

  private

  def claim_invitation(user_profile)
    existing_claim = InvitationClaim.find_by(invitation: @invitation, survey_profile: user_profile)
  
    if existing_claim
      flash[:alert] = "You have already claimed this invitation. Redirecting to your response."
      # Redirect to the existing response if it exists
      redirect_to edit_survey_response_path(existing_claim.survey_response) and return
    end
  
    sharecode_from_invitation = @invitation.parent_response.share_code
  
    @new_response_to_fill = SurveyResponse.create!(
      profile: user_profile,
      share_code: sharecode_from_invitation
    )
  
    InvitationClaim.create!(
      invitation: @invitation,
      survey_profile: user_profile,
      survey_response: @new_response_to_fill
    )
  end   
end