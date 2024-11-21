# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admins/index.html.erb', type: :view do
  let(:user_info) { { 'name' => 'John Doe' } }
  let(:survey_response) do
    double('SurveyResponse',
      id: 1,
      profile: double('Profile',
        first_name: 'Jane',
        last_name: 'Smith',
        role: 'Teacher',
        campus_name: 'High School',
        district_name: 'District A'
      ),
      created_at: Time.new(2024, 11, 15, 14, 30, 0)
    )
  end

  context 'when user is logged in' do
    before do
      allow(view).to receive(:session).and_return({ userinfo: user_info })
      assign(:survey_responses, [survey_response])
      render
    end

    it 'displays the admin dashboard title' do
      expect(rendered).to include('ADMIN DASHBOARD')
    end

    it 'welcomes the user by name' do
      expect(rendered).to include('Welcome John Doe')
    end

    it 'displays the survey responses table' do
      expect(rendered).to have_selector('table.table')
    end

    it 'shows the correct table headers' do
      expect(rendered).to have_selector('th', text: 'ID')
      expect(rendered).to have_selector('th', text: 'First Name')
      expect(rendered).to have_selector('th', text: 'Last Name')
      expect(rendered).to have_selector('th', text: 'Role')
      expect(rendered).to have_selector('th', text: 'Campus')
      expect(rendered).to have_selector('th', text: 'District')
    end

    it 'displays the correct survey response data' do
      expect(rendered).to have_selector('td', text: '1')
      expect(rendered).to have_selector('td', text: 'Jane')
      expect(rendered).to have_selector('td', text: 'Smith')
      expect(rendered).to have_selector('td', text: 'Teacher')
      expect(rendered).to have_selector('td', text: 'High School')
      expect(rendered).to have_selector('td', text: 'District A')
      expect(rendered).to have_selector('td', text: '2024-11-15 14:30:00')
    end

    it 'includes a link to view the survey' do
      expect(rendered).to have_link('View Survey', href: survey_response_path(survey_response))
    end
  end

  context 'when user is not logged in' do
    before do
      allow(view).to receive(:session).and_return({})
      render
    end

    it 'displays a welcome message' do
      expect(rendered).to include('Welcome.')
    end

    it 'informs the user they are not logged in' do
      expect(rendered).to include('You are not logged in. Please login.')
    end

    it 'does not display the admin dashboard' do
      expect(rendered).not_to include('ADMIN DASHBOARD')
    end

    it 'does not display the survey responses table' do
      expect(rendered).not_to have_selector('table.table')
    end
  end
end