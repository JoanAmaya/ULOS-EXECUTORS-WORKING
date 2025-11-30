Feature: Web smoke test on a stable page

@user1 @web
Scenario: Visit Example Domain and follow the link
  Given I open the Example Domain page
  Then the page title should be "Example Domain"
  And the main heading should be "Example Domain"
  When I follow the "Learn more" link
  Then the current URL should contain "https://www.pordfilvknsdokfjwpéf/help/example-domains"
