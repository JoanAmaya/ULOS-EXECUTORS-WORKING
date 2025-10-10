Background: 
  Given user "admin" exists
  And password "1234" is valid

@smoke @login
Scenario: Successful login
  Given user enters "admin"
  When user types "1234"
  Then system shows "Welcome"

@regression
Scenario Outline: Failed login attempts
  Given user enters "<username>"
  When user types "<password>"
  Then system shows "Invalid credentials"

Examples: | username | password |

