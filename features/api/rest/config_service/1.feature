Feature: Admin API Functionality Validation

  @SignupAPI @Positive @P1
  Scenario: Successful admin signup with valid credentials and secret
    Given the admin signup API is available
    When I send a POST request with username "admin-dev", password "admin@1234", and a valid base64 secret
    Then the response status code should be 201
    And the response body should contain a success message and user ID or token

  @SignupAPI @Negative @P1
  Scenario: Signup attempt with missing username
    Given the admin signup API is available
    When I send a POST request with password "admin@1234" and secret, but no username
    Then the response status code should be 400
    And the response body should contain an error message like "username is required"

  @SignupAPI @Negative @P1
  Scenario: Signup attempt with missing password
    Given the admin signup API is available
    When I send a POST request with username "admin-dev" and secret, but no password
    Then the response status code should be 400
    And the response body should contain an error message like "password is required"

  @SignupAPI @Negative @P1
  Scenario: Signup attempt with invalid secret
    Given the admin signup API is available
    When I send a POST request with an invalid secret
    Then the response status code should be 400 or 401
    And the response body should mention "invalid secret" or "unauthorized"

  @SignupAPI @Security @P1
  Scenario: Attempt SQL injection in username
    Given the admin signup API is available
    When I send a POST request with username "' OR 1=1 --" and valid password and secret
    Then the response should return 400 or 403
    And no user should be created

  @SignupAPI @Negative @P2
  Scenario: Signup with a username that already exists
    Given an admin with username "admin-dev" already exists
    When I try to register another admin with the same username
    Then the response status code should be 400
    And the response body should mention "username already exists"

  @SignupAPI @Negative @P2
  Scenario: Signup with a weak password
    Given the admin signup API is available
    When I send a POST request with a weak password like "123"
    Then the response status code should be 400
    And the response should include a message about "password policy violation"

  @SignupAPI @Negative @P2
  Scenario: Signup with empty request body
    Given the admin signup API is available
    When I send a POST request with an empty JSON body
    Then the response status code should be 400
    And the response should include a message like "invalid request body"

  # ------------------------- Login API Scenarios -------------------------

  @LoginAPI @Positive @P1
  Scenario: Successful login with valid credentials
    Given the admin login API is available
    When I send a POST request with correct username "admin-dev" and password "admin@1234"
    Then the response status code should be 200
    And the response should contain an authentication token or success message

  @LoginAPI @Negative @P1
  Scenario: Login with incorrect password
    Given the admin login API is available
    When I send a POST request with correct username and incorrect password
    Then the response status code should be 401
    And the response should include "Invalid credentials"

  @LoginAPI @Negative @P1
  Scenario: Login with incorrect username
    Given the admin login API is available
    When I send a POST request with incorrect username and correct password
    Then the response status code should be 401
    And the response should include "Invalid credentials"

  @LoginAPI @Negative @P1
  Scenario: Login with missing username
    Given the admin login API is available
    When I send a POST request with only the password field
    Then the response status code should be 400
    And the response should include "username is required"

  @LoginAPI @Negative @P1
  Scenario: Login with missing password
    Given the admin login API is available
    When I send a POST request with only the username field
    Then the response status code should be 400
    And the response should include "password is required"

  @LoginAPI @Security @P1
  Scenario: SQL injection attempt in username field
    Given the admin login API is available
    When I send a POST request with username "' OR '1'='1" and valid password
    Then the response should return 401 or 403
    And no user should be authenticated

  # ------------------------- Config Update API Scenarios -------------------------

  @ConfigUpdateAPI @Positive @P1
  Scenario: Update config with valid request
    Given the config API is available
    When I send a PUT request with valid headers and valid config data
    Then the response status code should be 200
    And the response should confirm successful update

  @ConfigUpdateAPI @Negative @P1
  Scenario: Update config without Authorization header
    Given the config API is available
    When I send a PUT request without the Authorization header
    Then the response status code should be 401
    And the response should contain "unauthorized" or similar error

  @ConfigUpdateAPI @Negative @P1
  Scenario: Update config with invalid token
    Given the config API is available
    When I send a PUT request with an invalid Bearer token
    Then the response status code should be 403 or 401
    And the response should contain "invalid token"

  @ConfigUpdateAPI @Negative @P2
  Scenario: Update config with invalid db_url format
    Given the config API is available
    When I send a PUT request with an invalid db_url
    Then the response status code should be 400
    And the response should indicate a format validation error

  @ConfigUpdateAPI @Positive @P3
  Scenario: Update config with additional optional fields
    Given the config API is available
    When I send a PUT request with extra fields not defined in the schema
    Then the response status code should be 200
    And the response should ignore or accept extra fields
