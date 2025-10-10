Feature: Session management and expiration

Then system initializes automatically
And user cache is cleared

Background:
  Given the session service is running
  And users are registered

Scenario: User login and token creation
  Given the user provides valid credentials
  When requests a token
  Then receives a valid token
  And expiration time is set

Scenario: Token renewal
  Given a valid token exists
  When the user renews session
  Then receives a new token

Scenario Outline: Invalid token use
  Given the user provides token <token>
  When attempting to access <resource>
  Then the system responds with <status>
  Examples:
    | token | resource | status |
    | expired | dashboard | unauthorized |
    | missing | profile | forbidden |
