class CreateInvitationClaims < ActiveRecord::Migration[7.1]
  def change
    create_table :invitation_claims do |t|
      t.references :invitation, null: false, foreign_key: true
      t.references :survey_profile, null: false, foreign_key: true
      t.references :survey_response, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :invitation_claims, [:invitation_id, :survey_profile_id], unique: true
  end
end

