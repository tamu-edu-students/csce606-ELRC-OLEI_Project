Feature: Initial UI Design
    Verify ui design

Background: Questions and responses exist
    Given the following questions exist:
    | text        | explanation | section  | 
    | Are you ok? | No I am not | 0 |
    | question 2 | explanation 2 | 1 |
    | question 3 | explanation 3 | 2 |
    | question 4 | explanation 4 | 3 |
    | question 5 | I am fine | 4 |


    Scenario: Verify survey profile page
        Given I am on the site
        And I try to login
        When I visit survey profile page
        Then I can see profile form

    Scenario: Verify survey form page
        Given I have logged in with user "1"
        Then I verify the survey questions are loaded

    Scenario: Verify survey qustions
        Given I have logged in with user "1"
        Then I verify the survey questions are loaded

    Scenario: Verify explanation on survey_responses page
        Given I have logged in with user "1" 
        And user 1 responses to question "Are you ok?"        
