# frozen_string_literal: true

# This is the model for the SurveyProfile
class SurveyProfile < ApplicationRecord
  enum role: {
    Department_Head: 0,
    Dean: 1,
    Provost: 2,
    President: 3, 
    Principal: 4, 
    Superintendent: 5,
    Teacher_leader:6

    # Principal: 0,
    # Supervisee: 1,
    # Supervisor: 2,
    # Team_Lead: 3, 
    # Provost: 4, 
    # President: 5

  }
  has_many :responses,
           foreign_key: :profile_id,
           class_name: 'SurveyResponse',
           dependent: :destroy

  has_many :claimed_invitations, class_name: 'Invitation', foreign_key: 'claimed_by_id'
end
