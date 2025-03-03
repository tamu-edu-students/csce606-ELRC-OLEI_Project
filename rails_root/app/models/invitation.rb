# frozen_string_literal: true

# User can create this invitation entity in the response page,
# once they finish their survey.
class Invitation < ApplicationRecord
  belongs_to :parent_response, class_name: 'SurveyResponse', foreign_key: 'parent_response_id'
  has_many :claims, class_name: 'InvitationClaim'
  has_many :claimed_by, through: :claims, source: :survey_profile
  has_many :responses, through: :claims, source: :survey_response

  validates_uniqueness_of :token

  before_create :generate_token

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end

