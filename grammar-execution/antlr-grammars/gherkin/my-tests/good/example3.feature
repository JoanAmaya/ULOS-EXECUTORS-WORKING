Feature: User account management

Background:
  Given system is running
  And database connection is active
  When admin logs in with "root" and "securePass123"
  Then dashboard shows "Welcome administrator"

@user @creation
Scenario: Create a new user
  Given admin navigates to "User Management"
  When admin clicks "Add User"
  Then form for "New User" appears
  And button "Save" is visible
  But field "Password" is empty

@user @update
Scenario: Update user information
  Given user "john_doe" exists
  When admin edits "john_doe"
  And changes "email" to "john@newmail.com"
  Then message "User updated successfully" appears

@user @outline @delete
Scenario Outline: Delete existing users
  Given admin selects "<username>" from user list
  When admin clicks "Delete"
  Then confirmation message "User <username> deleted" appears

Examples: | username |
| alice   |
| bob     |
| carol   |
