class CreateInvitationClaims < ActiveRecord::Migration[7.1]
  def change
    create_table :invitation_claims do |t|
      t.references :invitation, null: false, foreign_key: true
      t.references :survey_profile, null: false, foreign_key: true
      t.references :survey_response, null: false, foreign_key: true

      t.timestamps
    end
  end
end
