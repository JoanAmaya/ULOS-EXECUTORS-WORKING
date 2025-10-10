Feature: Payment validation and transaction logging

Background:
  Given the payment API is online
  And user authentication is enabled

Scenario: Validate successful payment
  Given the user enters valid card information
  When Then
  Then the system marks the transaction as completed
  And the user receives a confirmation email

Scenario: Validate declined payment
  Given the user enters an expired card
  When the transaction is sent for authorization
  Then the system rejects the payment
  And shows an error message "Card expired"
