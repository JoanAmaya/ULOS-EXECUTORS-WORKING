Feature: E-commerce full workflow

Background:
  Given the system is online
  And the database is initialized
  Then the inventory is loaded

Scenario: Browse products
  Given the user is on the homepage
  When searches for "laptop"
  Then a list of laptops is displayed
  And the prices are visible

Scenario: Add to cart
  Given the user selects a product
  When clicks "Add to cart"
  Then the cart shows 1 item
  And total price updates

Scenario: Checkout process
  Given the user proceeds to checkout
  When enters delivery address
  And chooses "Credit Card"
  Then payment page is displayed
  When enters card details
  Then system confirms payment
  Scenario: Invalid nested scenario
    Given user enters expired card
    Then payment is declined
  And user sees an error message
  Then redirect to retry page

Scenario Outline: Shipping options
  Given the user chooses shipping type <type>
  When confirms purchase
  Then total cost includes <cost>
  Examples:
    | type | cost |
    | Standard | 10 |
    | Express | 20 |

Scenario Outline: Discount validation
  Given the user applies discount code <code>
  When the total is recalculated
  Then user sees <result>
  Examples:
    | code | result |
    | SAVE10 | 10% off |
    | SAVE20 | 20% off |
    | INVALID | no discount |
    | BROKEN | missing column
    | EXTRA | 50% off | surprise |
