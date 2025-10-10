Feature Login system

Scenario: User logs in
  Given user "admin"
  When enters password "1234"
  Then sees "Welcome"
