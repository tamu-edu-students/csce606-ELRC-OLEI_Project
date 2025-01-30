# frozen_string_literal: true

class SurveyProfile < ApplicationRecord
  enum role: {
    "Department Head": 0,
    "Dean": 1,
    "Provost": 2,
    "President": 3, 
    "Principal": 4, 
    "Superintendent": 5,
    "Teacher Leader": 6,
  }

  belongs_to :supervisor, class_name: 'SurveyProfile', optional: true
  has_many :supervisees, class_name: 'SurveyProfile', foreign_key: 'supervisor_id'

  has_many :responses,
           foreign_key: :profile_id,
           class_name: 'SurveyResponse',
           dependent: :destroy

  has_many :claimed_invitations, class_name: 'Invitation', foreign_key: 'claimed_by_id'

  after_create :set_role_relationships

  private

  def set_role_relationships
    case role
    when "Department Head"
      self.supervisor = SurveyProfile.find_by(role: "Dean")
      self.supervisees << SurveyProfile.where(role: "Teacher Leader")
    when "Dean"
      self.supervisor = SurveyProfile.find_by(role: "Provost")
      self.supervisees << SurveyProfile.where(role: "Department Head")
    when "Provost"
      self.supervisor = SurveyProfile.find_by(role: "President")
      self.supervisees << SurveyProfile.where(role: "Dean")
    when "President"
      self.supervisees << SurveyProfile.where(role: ["Provost", "Principal"])
    when "Principal"
      self.supervisor = SurveyProfile.find_by(role: "President")
      self.supervisees << SurveyProfile.where(role: "Superintendent")
    when "Superintendent"
      self.supervisor = SurveyProfile.find_by(role: "Principal")
      self.supervisees << SurveyProfile.where(role: "Teacher Leader")
    when "Teacher Leader"
      self.supervisor = SurveyProfile.find_by(role: ["Department Head", "Superintendent"].sample)
    end
  end
end
