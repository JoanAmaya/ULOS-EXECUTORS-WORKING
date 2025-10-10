Feature: Order processing and invoice generation

Background:
  Given the database is initialized
  And test users exist in the system

Scenario: Process a valid order
  Given the customer selects 3 products
  When the order is submitted
  Then the system generates an invoice
  And sends an email confirmation

Examples:
  | order_id | total |
  | 1001      | 59.99 |
  | 1002      | 42.50 |

Scenario Outline: Validate stock levels
  Given the warehouse has <available> units
  When the customer orders <requested> units
  Then the system marks <status>

Examples:
  | available | requested | status  |
  | 10        | 3         | valid   |
  | 2         | 5         | invalid |
