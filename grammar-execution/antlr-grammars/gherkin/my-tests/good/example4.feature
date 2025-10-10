Feature: E-commerce platform checkout process

Background:
  Given the online store "SuperShop" is running
  And inventory database is connected
  And user "alice" is registered
  When user logs in with "alice" and "password123"
  Then system displays "Welcome back, alice"
  And cart is initially empty

@cart @add @smoke
Scenario: Add a single product to the cart
  Given user navigates to "Electronics"
  When user selects "Smartphone"
  And user clicks "Add to cart"
  Then cart contains "Smartphone"
  And total price equals "799.99"

@cart @update
Scenario: Update quantity in the cart
  Given user adds "Laptop" to the cart
  When user increases quantity to "2"
  Then cart total updates to "2599.98"
  And label "2 items" is visible
  But discount banner "Black Friday" is not visible

@cart @remove
Scenario: Remove an item from the cart
  Given user adds "Headphones" to the cart
  And user adds "Mouse" to the cart
  When user removes "Mouse"
  Then cart shows only "Headphones"
  And total price equals "199.99"

@checkout @positive
Scenario: Successful checkout with one item
  Given cart has "Smartwatch"
  When user proceeds to checkout
  And enters payment details "VISA 1234"
  Then confirmation message "Payment successful" appears
  And email "Order confirmation" is sent

@checkout @negative
Scenario Outline: Checkout fails with invalid payment method
  Given cart has "<product>"
  When user proceeds to checkout
  And enters payment details "<payment>"
  Then error message "<error>" appears
  But order is not created

Examples: | product     | payment        | error                   |
| TV           | EXPIRED_CARD   | Invalid payment method   |
| Console      | EMPTY_CARD     | Payment details missing  |
| Camera       | BLOCKED_CARD   | Payment not authorized   |

@admin @regression
Scenario: Admin views completed orders
  Given admin logs in with "root" and "adminpass"
  When admin navigates to "Orders"
  Then page shows "List of Completed Orders"
  And at least "3" orders are displayed

@admin @outline @report
Scenario Outline: Admin generates sales report by category
  Given admin is on "Reports" page
  When admin selects "<category>"
  Then report for "<category>" is generated
  And message "Report generated successfully" appears

Examples: | category    |
| Electronics |
| Home        |
| Toys        |
| Sports      |
