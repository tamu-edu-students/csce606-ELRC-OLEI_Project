class AddSupervisorIdToSurveyProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :survey_profiles, :supervisor_id, :integer
  end
end
