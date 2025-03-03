# frozen_string_literal: true

# Helper methods for the survey responses controller
module SurveyResponsesHelper
  # method to calculate the average score of a survey response
  def average_score(survey_response)
    # returns the average score of the survey response
    survey_response.answers.average(:choice).to_f
  end

  # method to format the date of a survey response
  def formatted_date(survey_response)
    survey_response.created_at.strftime('%B %d, %Y')
  end

  #  method to find the user of a survey response
  def user_of_response(survey_response)
    # returns profile_id of the survey response
    survey_response.profile_id
  end

  def supervisee_average_by_part(response)
    parts = [
      [0, 1],
      [2],
      [3],
      [4, 5]
    ]
  
    supervisee_profiles = find_supervisees(response)
  
    parts.map do |sections|
      answers = {}
      supervisee_profiles.each do |profile|
        survey_response = profile.responses.find_by(share_code: response.share_code)
        next unless survey_response
  
        survey_response.answers.includes(:question).select { |ans| sections.include? ans.question.section }.each do |ans|
          answers[ans.question_id] = (answers[ans.question_id] || 0) + ans.choice
        end
      end
  
      answers.transform_values! { |v| v.to_f / supervisee_profiles.count }
    end
  end
  
  def average_of_supervisees(response)
    supervisee_profiles = find_supervisees(response)
    total_scores = Array.new(97, 0)
    count_scores = Array.new(97, 0)
  
    return nil if supervisee_profiles.empty?
  
    supervisee_profiles.each do |profile|
      survey_response = profile.responses.find_by(share_code: response.share_code)
      next unless survey_response
  
      survey_response.answers.each do |ans|
        total_scores[ans.question_id] += ans.choice.to_f
        count_scores[ans.question_id] += 1
      end
    end
  
    # Calculate average scores
    average_scores = total_scores.map.with_index do |total, index|
      count = count_scores[index]
      count > 0 ? (total / count).round(2) : nil
    end
  
    average_scores
  end  
  

  def find_supervisor(response)
    child_profile = response.profile
  
    supervisor_role = case child_profile.role
    when "Department Head"
      "Dean"
    when "Dean"
      "Provost"
    when "Provost"
      "President"
    when "Principal"
      "President"
    when "Superintendent"
      "Principal"
    when "Teacher Leader"
      ["Department Head", "Superintendent"]
    else
      nil
    end
  
    return nil if supervisor_role.nil?
  
    # Instead of using parent_response, we'll search for a supervisor based on the share_code
    supervisor_profiles = SurveyProfile.where(role: supervisor_role)
    supervisor_response = SurveyResponse.joins(:profile)
                                        .where(share_code: response.share_code, profile: supervisor_profiles)
                                        .first
  
    supervisor_response
  end
  
  
  def find_supervisees(response)
    parent_profile = response.profile
  
    # Collect all profiles associated with survey responses linked to the invitation
    child_profiles = response.invitations.flat_map do |invitation|
      invitation.responses.map(&:profile)
    end.compact
  
    supervisee_roles = case parent_profile.role
    when "Department Head"
      ["Teacher Leader"]
    when "Dean"
      ["Department Head"]
    when "Provost"
      ["Dean"]
    when "President"
      ["Provost", "Principal"]
    when "Principal"
      ["Superintendent"]
    when "Superintendent"
      ["Teacher Leader"]
    else
      []
    end
  
    # Filter profiles by supervisee roles
    child_profiles.select { |profile| supervisee_roles.include?(profile.role) }
  end

  def get_answer(response, question_id)
    response.answers.where(question_id:).first!.choice
  rescue StandardError
    nil
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_supervisee_part_difference(response)
    parts = [
      [0, 1],
      [2],
      [3],
      [4, 5]
    ]

    supervisee_avgs = supervisee_average_by_part(response)

    parts.each_with_index.map do |sections, idx|
      answers = response.answers.select { |ans| sections.include? ans.question.section }
      supervisee_answers = supervisee_avgs[idx]

      if answers.empty?
        0
      else
        difference = 0
        nonempty_answers = answers.reject { |ans| ans.choice.nil? }

        nonempty_answers.each do |x|
          supervisee_choice = supervisee_answers[x.question_id]
          difference += (x.choice - supervisee_choice).abs unless supervisee_choice.nil?
        end

        length = nonempty_answers.length - supervisee_answers.select { |_, v| v.nil? }.length

        (difference.to_f / length).round
      end
    end
  end

  def get_part_difference(response, other)
    parts = [
      [0, 1],
      [2],
      [3],
      [4, 5]
    ]

    parts.map do |sections|
      answers = response.answers.select { |ans| sections.include? ans.question.section }
      other_answers = other.answers.select { |ans| sections.include? ans.question.section }

      if answers.empty?
        0
      else
        difference = 0
        nonempty_answers = answers.reject { |ans| ans.choice.nil? }
        nonempty_answers.each do |x|
          other_choice = other_answers.detect { |y| x.question_id == y.question_id }
          difference += (x.choice - other_choice.choice).abs unless other_choice.nil?
        end

        length = nonempty_answers.length - other_answers.select { |ans| ans.choice.nil? }.length
        (difference.to_f / length).round
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
