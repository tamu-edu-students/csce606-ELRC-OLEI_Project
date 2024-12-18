Feature: Survey Profile Creation upon successful OAuth login
  Verify survey profile creation and login behavior.

  Scenario: User logs in and creates a survey profile
    Given that I am on the homepage
    And I try to login
    And I have never created a survey profile
    Then I am redirected to the create survey profile page
    And I fill in my first and last name, district name, campus name, and organization role, and click create
    Then a survey profile is created with the proper information
    Then I am redirected to the home page

  Scenario: User that has already created a survey profile logs in
    Given that I am on the homepage
    And I have created a survey profile previously
    And I try to login
    Then I am redirected to the home page 
    And I am greeted with a welcome message
