Feature: Data Submission
    Test submission buttons and their functions on the survey page

Background: Questions and responses exist
    Given many questions exist
    Scenario: Not logged in
        Given I have not logged in
        When I visit new survey page
        Then I should be on root page

    Scenario: Not create user profile
        Given I have logged in with user "1"
        And I have no survey profile
        When I visit new survey page
        Then I am redirected to the create survey profile page

    Scenario: See Next button
        Given I have logged in with user "1"
        Then I should see Next button

    Scenario: See Save button
        Given I have logged in with user "1"
        Then I should see Save button

    Scenario: See Previous button
        Given I have logged in with user "1"
        Then I should see Previous button

    Scenario: Should not see Submit button
        Given I have logged in with user "1"
        Then I should not see Submit button
        
    Scenario: Analysis displays correct values
        Given I have logged in with user "1"
        And I click Submit button
        
    Scenario: Analysis displays tetrahedron
        Given I have logged in with user "1"
        And I have created survey response for user "1"
        When I go to survey result page 1
        Then the analysis results displays the SLT summary