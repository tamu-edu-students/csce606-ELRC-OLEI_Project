# frozen_string_literal: true

# Controller for survey responses

# rubocop:disable Metrics/ClassLength
class SurveyResponsesController < ApplicationController
  include Pagination
  helper_method :invite_token

  before_action :set_survey_data, only: %i[show edit update destroy]
  before_action :set_survey_sections, only: %i[show edit update survey new]

  # GET /survey_responses or /survey_responses.json
  def index
    if params[:query].present?

      @survey_responses = Invitation.where(token: params[:query]).map(&:response)
      flash[:warning] = "No survey responses found for share code #{params[:query]}" if @survey_responses.empty?
    else
      @survey_responses = SurveyResponse.all
    end
  end

  # GET /survey_responses/1 or /survey_responses/1.json
  def show
    return return_to_root 'You are not logged in.' if current_user_id.nil?
  
    return return_to_root 'You cannot view this result.' if !user_is_admin? && (current_user_id != @survey_response&.profile&.user_id)
  
    set_survey_sections # Ensure sections are correctly set
  
    invited_survey = InvitationClaim.exists?(survey_response_id: @survey_response.id)
  
    flash.keep(:warning)
  
    respond_to do |format|
      if invited_survey
        format.html { render 'survey_responses/show_invitation' }
        format.xlsx do
          response.headers['Content-Disposition'] = "attachment; filename=evaluation_survey_#{@survey_response.id}.xlsx"
        end
      else
        format.html { render 'survey_responses/show' }
        format.xlsx do
          response.headers['Content-Disposition'] = "attachment; filename=survey_response_#{@survey_response.id}.xlsx"
        end
      end
    end
  end
  
  def current_user_id
    session[:userinfo]['sub'] if session.dig(:userinfo, 'sub').present? && !session[:userinfo]['sub'].nil?
  end

  def new
    # login check is done in secure.rb
    logger.info '========== new triggered =========='

    @pagination, @questions, @section = paginate(collection: SurveyQuestion.all, params: { per_page: 10, page: 1 })
    @survey_response = SurveyResponse.new
    return return_to_root 'You are not logged in.' if current_user_id.nil?
    return return_to_root 'Your profile could not be found. Please complete your profile.' unless SurveyProfile.exists?(user_id: current_user_id)

    @survey_profile = SurveyProfile.find_by(user_id: current_user_id)

    session[:survey_id] = nil
    session[:page_number] = 1
  end

  # GET /survey/page/:page
  def survey
    logger.info '========== survey triggered =========='
    @pagination, @questions, @section = paginate(collection: SurveyQuestion.all, params: { per_page: 10, page: params[:page] })
    @survey_response = SurveyResponse.find_by_id(session[:survey_id])
    render :survey
  end

  # GET /survey_responses/1/edit
  def edit
    logger.info '========== edit triggered =========='
    return return_to_root 'You are not logged in.' if current_user_id.nil?
    return return_to_root 'Your profile could not be found. Please complete your profile.' unless SurveyProfile.exists?(user_id: current_user_id)
    return return_to_root 'You cannot edit this result.' if current_user_id != @survey_response.profile.user_id

    # Initialize page number to 1 if not already set
    session[:page_number] = 1 if session[:page_number].nil?

    @pagination, @questions, @section = paginate(collection: SurveyQuestion.all, params: { per_page: 10, page: session[:page_number] })
  end

  # POST /survey_responses or /survey_responses.json
  # rubocop:disable all
  def create
    logger.info '========== create triggered =========='
    return respond_with_error 'invalid_form' if invalid_form?
    return return_to_root 'You are not logged in.' if current_user_id.nil?
    return return_to_root 'Your profile could not be found. Please complete your profile.' unless SurveyProfile.exists?(user_id: current_user_id)

    @survey_response = SurveyResponse.create_from_params current_user_id, survey_response_params
    session[:survey_id] = @survey_response.id


    respond_to do |format|
      if params[:commit].in?(%w[Save Next])
        format.html do
          session[:page_number] += 1
          redirect_to edit_survey_response_path(@survey_response)
        end
      elsif params[:commit] == 'Previous'
        format.html do
          session[:page_number] -= 1
          redirect_to edit_survey_response_path(@survey_response)
        end
      else
        format.html do
          redirect_to survey_response_url(@survey_response), notice: 'Survey response was successfully created.'
        end
        format.json { render :show, status: :created, location: @survey_response }
      end
    end
  end

  def get_answer(response, question_id)
    answer = response.answers.find_by(question_id: question_id)
    answer&.choice
  end
  
  def get_supervisee_average(question_id)
    # Assuming you have logic to calculate the average of supervisees' answers for a given question.
    supervisees_responses = SuperviseeResponse.where(question_id: question_id)
    supervisees_responses.average(:choice).round if supervisees_responses.exists?
  end

  # PATCH/PUT /survey_responses/1 or /survey_responses/1.json
  def update
    logger.info '========== update triggered =========='
    return respond_with_error 'invalid form' if invalid_form?
    return return_to_root 'You are not logged in.' if current_user_id.nil?
    return return_to_root 'Your profile could not be found. Please complete your profile.' unless SurveyProfile.exists?(user_id: current_user_id)
    return return_to_root 'You cannot update this result.' if current_user_id != @survey_response.profile.user_id

    unless survey_response_params.nil?
      @survey_response.add_from_params current_user_id, survey_response_params
    end

    respond_to do |format|
      if params[:commit].in?(%w[Save Next])
        format.html do
          session[:page_number] += 1
          redirect_to edit_survey_response_path(@survey_response)
        end
      elsif params[:commit] == 'Previous'
        format.html do
          session[:page_number] -= 1
          redirect_to edit_survey_response_path(@survey_response)
        end
      else
        format.html do
          redirect_to survey_response_url(@survey_response), notice: 'Survey response was successfully created.'
        end
        format.json { render :show, status: :created, location: @survey_response }
      end
    end
  end
  # rubocop:enable all

  # DELETE /survey_responses/1 or /survey_responses/1.json
  def destroy
    ActiveRecord::Base.transaction do
      # Delete associated survey answers
      SurveyAnswer.where(response_id: @survey_response.id).destroy_all
  
      # Delete associated invitations
      Invitation.where(response_id: @survey_response.id).destroy_all
  
      # Finally, destroy the survey response
      @survey_response.destroy!
    end
  
    respond_to do |format|
      if user_is_admin?
        format.html { redirect_to admin_dashboard_path, notice: 'Survey response was successfully destroyed.' }
      else
        format.html { redirect_to root_path, notice: 'Survey response was successfully destroyed.' }
      end
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: "Failed to destroy survey response: #{e.message}" }
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end
  
  

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_survey_data
    logger.info '========== set_survey_data triggered =========='
    @survey_response = SurveyResponse.find_by(id: params[:id])
    if @survey_response.nil?
      flash[:alert] = 'Survey not found'
      redirect_to root_path
    else
      @questions = @survey_response.questions
    end
  end  

  # rubocop:disable Metrics/MethodLength
  def set_survey_sections
    logger.info '========== set_survey_sections triggered =========='
  
    return return_to_root('You are not logged in.') if current_user_id.nil?
    return return_to_root('Your profile could not be found. Please complete your profile.') unless SurveyProfile.exists?(user_id: current_user_id)
  
    @survey_profile = SurveyProfile.find_by(user_id: current_user_id)
    
    # Check if the user started from an invitation (stored in session)
    started_from_invitation = session[:invitation].present?
    
    # If the user is taking their own survey (new or continuing)
    unless started_from_invitation
      # Self-assessment survey
      @sections = [
        {
          title: 'Part 1: Leadership Behavior - Management',
          prompt: 'To what extent do you agree that the following behaviors reflect your personal leadership approach?'
        },
        {
          title: 'Part 1: Leadership Behavior - Interpersonal',
          prompt: 'To what extent do you agree that the following behaviors reflect your interpersonal leadership style?'
        },
        {
          title: 'Part 2. External Forces',
          prompt: 'To what extent do you believe these external factors influence your leadership?'
        },
        {
          title: 'Part 3. Organizational Structure',
          prompt: 'To what extent do you agree that the following characteristics describe your organization’s structure?'
        },
        {
          title: 'Part 4. Values, Attitudes, and Beliefs',
          prompt: 'To what extent do you agree that the following characteristics represent your perspectives?'
        },
        {
          title: 'Part 4. Values, Attitudes, and Beliefs',
          prompt: 'To what extent do you agree that the following characteristics apply to your external community (e.g., leadership, management, stakeholders)?'
        }
      ]
    else
      # Evaluation survey (Taken via invitation link)
      @sections = [
        {
          title: 'Part 1: Leadership Behavior - Management',
          prompt: 'To what extent do you agree that the following behaviors reflect the leadership approach of the surveyed individual?'
        },
        {
          title: 'Part 1: Leadership Behavior - Interpersonal',
          prompt: 'To what extent do you agree that the following behaviors reflect the interpersonal leadership style of the surveyed individual?'
        },
        {
          title: 'Part 2. External Forces',
          prompt: 'To what extent do you believe these external factors influence the surveyed individual’s leadership?'
        },
        {
          title: 'Part 3. Organizational Structure',
          prompt: 'To what extent do you agree that the following characteristics describe the organization’s structure from the perspective of the surveyed individual?'
        },
        {
          title: 'Part 4. Values, Attitudes, and Beliefs',
          prompt: 'To what extent do you agree that the following characteristics represent the perspectives of the surveyed individual?'
        },
        {
          title: 'Part 4. Values, Attitudes, and Beliefs',
          prompt: 'To what extent do you agree that the following characteristics apply to the external community of the surveyed individual (e.g., leadership, management, stakeholders)?'
        }
      ]
    end
  end   
  # rubocop:enable Metrics/MethodLength
  def invalid_form?
    return false if survey_response_params.nil?

    survey_response_params.values.any? { |value| value.nil? || value.empty? }
  end

  def respond_with_error(message, status = :unprocessable_entity)
    respond_to do |format|
      format.html do
        redirect_to new_survey_response_path, notice: message, status:
      end
      format.json { render json: { error: message }, status: }
    end
  end

  def return_to_root(message)
    respond_to do |format|
      format.html do
        redirect_to root_url, notice: message
      end
      format.json { render json: { error: message }, status: }
    end
  end

  def survey_response_params
    return unless params.include? :survey_response

    params.require(:survey_response).permit!
  end

  def invite_token(response)
    invitation = Invitation.find_by(response_id: response.id)
    invitation ? invitation.token : 'N/A'
  end
end
