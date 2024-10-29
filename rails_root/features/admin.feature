Feature: Admin redirection based on user roles

Scenario: User with 'Admin' role is redirected to admin dashboard
  Given I am logged in as a user with 'Admin' role
  When I access the login page
  Then I should be redirected to the admin dashboard

Scenario: User without 'Admin' role is redirected to home
  Given I am logged in as a user with '' role
  When I access the login page
  Then I should be redirected to the new survey page