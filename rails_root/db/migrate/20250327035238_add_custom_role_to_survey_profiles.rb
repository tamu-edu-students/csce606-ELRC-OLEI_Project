class AddCustomRoleToSurveyProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :survey_profiles, :custom_role, :string
  end
end
