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

  # method to find the user of a survey response
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

  def average_of_supervisors(response)
    child_profile = response.profile
  
    # Find all supervisor roles above the current profile
    supervisor_roles = SurveyProfile.roles.keys.select { |role| SurveyProfile.roles[role] < SurveyProfile.roles[child_profile.role] }
    return nil if supervisor_roles.empty?
  
    # Find all supervisors' profiles
    supervisor_profiles = SurveyProfile.where(role: supervisor_roles)
  
    # Find all survey responses from supervisors using the same share_code
    supervisor_responses = SurveyResponse.joins(:profile)
                                         .where(share_code: response.share_code, profile: supervisor_profiles)
  
    return nil if supervisor_responses.empty? # If no supervisors have responded
  
    # Calculate the average choice for each question
    total_scores = Hash.new(0)
    count_scores = Hash.new(0)
  
    supervisor_responses.each do |supervisor_response|
      supervisor_response.answers.each do |ans|
        total_scores[ans.question_id] += ans.choice.to_f
        count_scores[ans.question_id] += 1
      end
    end
  
    # Compute averages
    average_scores = total_scores.transform_values { |total| (total / count_scores[total_scores.key(total)]).round(2) }
  
    average_scores
  end  

  # Finds all supervisees (anyone below in the hierarchy)
  def find_supervisees(response)
    parent_profile = response.profile

    supervisee_roles = SurveyProfile.roles.keys.select { |role| SurveyProfile.roles[role] > SurveyProfile.roles[parent_profile.role] }

    return [] if supervisee_roles.empty?

    response.invitations.flat_map do |invitation|
      invitation.responses.map(&:profile)
    end.compact.select { |profile| supervisee_roles.include?(profile.role) }
  end

  def get_answer(response, question_id)
    if response.is_a?(Hash)
      return response[question_id] || 'NE' # Fetch from the hash, or return "NE" if missing
    end
  
    response.answers.where(question_id: question_id).first&.choice || 'NE'
  rescue StandardError
    'NE'
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
      
      # Handle both individual response objects and averaged hashes
      other_answers = other.is_a?(Hash) ? other : other.answers.select { |ans| sections.include? ans.question.section }
  
      if answers.empty?
        0
      else
        difference = 0
        nonempty_answers = answers.reject { |ans| ans.choice.nil? }
  
        nonempty_answers.each do |x|
          # Get the choice value from `other_answers`
          other_choice = other.is_a?(Hash) ? other[x.question_id] : other_answers.detect { |y| x.question_id == y.question_id }&.choice
          difference += (x.choice - other_choice).abs unless other_choice.nil?
        end
  
        length = nonempty_answers.length - other_answers.select { |ans| ans.nil? }.length
        (length > 0) ? (difference.to_f / length).round : 0
      end
    end
  end  
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
