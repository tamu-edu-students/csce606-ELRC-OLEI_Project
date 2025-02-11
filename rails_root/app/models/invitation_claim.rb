# frozen_string_literal: true

class InvitationClaim < ApplicationRecord
  belongs_to :invitation
  belongs_to :survey_profile
  belongs_to :survey_response

  validates :invitation_id, uniqueness: { scope: :survey_profile_id }
end
