Feature: Shopping cart management

Background:
  Given the database is initialized
  And the user table exists

Scenario: Add item to cart
  Given the user is logged in
  When adds an item "Laptop" to the cart
  Then the item appears in the cart list

Scenario: Remove item from cart
  Given the user has an item in the cart
  When removes the item
  Then the cart should be empty

Scenario Outline: Checkout process
  Given the user has <items> in the cart
  When proceeds to payment
  Then the total price should be calculated
  Examples:
    | items |
    | 1 |
    | 3 |
    
Background:
  Given the system resets the cart data
  Then all carts should be empty again
