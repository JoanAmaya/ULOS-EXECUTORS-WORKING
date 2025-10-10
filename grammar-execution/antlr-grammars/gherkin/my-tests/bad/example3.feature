Feature: Payment processing

Background:
  Given the payment gateway is online
  And the user has a valid credit card

Scenario: Successful payment
  Given the user adds a product to the cart
  When proceeds to checkout
  Then sees the payment page
  And enters valid payment details
  Then the system confirms the order

Scenario Outline: Payment with multiple cards
  Given the user has <card_type> card
  When attempts to make a purchase of <amount>
  Then the system should respond with <response>
  Examples:
    | card_type | amount | response |
    | Visa | 100 | Approved |
    | MasterCard | 250 | Approved
    | Amex | | Declined |
    | Discover | 400 | Declined |
