# frozen_string_literal: true

class SurveyProfile < ApplicationRecord
  enum role: {
    "Board Member": 0,
    "Superintendent": 1,
    "Assistant/Associate Superintendent": 2,
    "Principal": 3,
    "Assistant Principal": 4,
    "Counselor": 5,
    "Teacher Leader (Specialist)": 6,
    "Teacher": 7,
    "Other Instructional Staff": 8,
    "Non-Instructional Staff": 9
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
    role_index = SurveyProfile.roles[role]
    higher_roles = SurveyProfile.roles.select { |_, index| index < role_index }.keys
    lower_roles = SurveyProfile.roles.select { |_, index| index > role_index }.keys

    self.supervisor = SurveyProfile.where(role: higher_roles).first
    self.supervisees << SurveyProfile.where(role: lower_roles)
  end
end

