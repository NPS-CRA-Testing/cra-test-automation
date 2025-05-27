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
Scenario: Signup attempt with invalid base64 secret
  Given the admin signup API is available
  When I send a POST request with an invalid secret that is not base64-encoded
  Then the response status code should be 400 or 401
  And the response body should mention "invalid secret" or "unauthorized"

@SignupAPI @Negative @P2
Scenario: Signup with a username that already exists
  Given an admin with username "admin-dev" already exists
  When I try to register another admin with the same username
  Then the response status code should be 409
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

@SignupAPI @Security @P1
Scenario: Signup using an invalid content-type header
  Given the admin signup API is available
  When I send a POST request with Content-Type "text/plain" instead of "application/json"
  Then the response status code should be 415
  And the response should include "unsupported media type"

@SignupAPI @Security @P1
Scenario: Attempt SQL injection in username
  Given the admin signup API is available
  When I send a POST request with username "' OR 1=1 --" and valid password and secret
  Then the response should return 400 or 403
  And no user should be created

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

@LoginAPI @Negative @P2
Scenario: Login with empty request body
  Given the admin login API is available
  When I send a POST request with an empty JSON body
  Then the response status code should be 400
  And the response should include "invalid request"

@LoginAPI @Security @P1
Scenario: SQL injection attempt in username field
  Given the admin login API is available
  When I send a POST request with username "' OR '1'='1" and valid password
  Then the response should return 401 or 403
  And no user should be authenticated

@LoginAPI @Security @P1
Scenario: SQL injection attempt in password field
  Given the admin login API is available
  When I send a POST request with valid username and password "' OR '1'='1"
  Then the response should return 401 or 403
  And no user should be authenticated

@LoginAPI @Security @P2
Scenario: Login with invalid content-type
  Given the admin login API is available
  When I send a POST request with content-type set to "text/plain"
  Then the response status code should be 415
  And the response should include "unsupported media type"

@LoginAPI @Security @P3
Scenario: Login brute force protection (rate limiting)
  Given the admin login API is available
  When I send more than 5 failed login attempts in a short period
  Then the API should block or delay further attempts
  And return status code 429 or appropriate error


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
Scenario: Update config with missing required fields
  Given the config API is available
  When I send a PUT request without the db_url or redis-url field
  Then the response status code should be 400
  And the response should specify the missing fields

@ConfigUpdateAPI @Negative @P2
Scenario: Update config with invalid db_url format
  Given the config API is available
  When I send a PUT request with an invalid db_url
  Then the response status code should be 400
  And the response should indicate a format validation error

@ConfigUpdateAPI @Negative @P2
Scenario: Update config with empty request body
  Given the config API is available
  When I send a PUT request with an empty JSON object
  Then the response status code should be 400

@ConfigUpdateAPI @Negative @P3
Scenario: Update config with invalid HTTP method
  Given the config API is available
  When I send a GET request instead of PUT
  Then the response status code should be 405 Method Not Allowed

@ConfigUpdateAPI @Positive @P3
Scenario: Update config with additional optional fields
  Given the config API is available
  When I send a PUT request with extra fields not defined in the schema
  Then the response status code should be 200
  And the response should ignore or accept extra fields

@WithdrawalConfigAPI @Positive @P1
Scenario: Successfully retrieve config for dev withdrawal service
  Given the config API is available
  When I send a GET request with a valid Bearer token
  Then the response status should be 200
  And the response should contain expected config keys like "db_url", "redis-url", etc.

@WithdrawalConfigAPI @Negative @P1
Scenario: Access config without Authorization header
  Given the config API is available
  When I send a GET request without the Authorization header
  Then the response should return 401 Unauthorized

@WithdrawalConfigAPI @Negative @P3
Scenario: Access config with wrong service name
  Given the config API is available
  When I send a GET request to /config/api/v1/config/dev/wrong-service
  Then the response should return 404 Not Found

@WithdrawalKeyAPI @Positive @P1
Scenario: Successfully retrieve config key for withdrawal service
  Given the config key API is available
  When I send a GET request with a valid Bearer token
  Then the response status should be 200
  And the response should include the key details

@WithdrawalKeyAPI @Negative @P1
Scenario: Access config key without Authorization header
  Given the config key API is available
  When I send a GET request without the Authorization header
  Then the response should return 401 Unauthorized

@WithdrawalKeyAPI @Negative @P1
Scenario: Access config key with an invalid token
  Given the config key API is available
  When I send a GET request with a fake or malformed token
  Then the response should return 403 Forbidden or 401 Unauthorized

@WithdrawalKeyAPI @Negative @P2
Scenario: Access config key for an invalid environment
  Given the config key API is available
  When I send a GET request to /config/api/v1/config/prod/withdrawal/key
  Then the response should return 404 Not Found

@WithdrawalKeyAPI @Negative @P2
Scenario: Access config key for an invalid service
  Given the config key API is available
  When I send a GET request to /config/api/v1/config/dev/unknown/key
  Then the response should return 404 Not Found

@WebhookAPI @Positive @P1
Scenario: Successfully create a webhook
  Given a valid webhook payload with environment, serviceName, and url
  When I send a POST request with Authorization token
  Then the response should return 201 Created or 200 OK

@WebhookAPI @Negative @P1
Scenario: Create webhook without Authorization
  When I send a POST request without token
  Then I should receive 401 Unauthorized

@WebhookAPI @Negative @P1
Scenario: Create webhook with missing required field
  When I send a POST request without the url field
  Then I should receive 400 Bad Request

@WebhookAPI @Negative @P2
Scenario: Create webhook with duplicate data
  Given a webhook already exists with same url, service, and method
  When I try to POST it again
  Then the API should return 409 Conflict or proper error

@WebhookAPI @Positive @P1
Scenario: Fetch all webhooks for withdrawal service in dev
  When I send a GET request with valid token
  Then I should get 200 OK
  And the response should contain a list of configured webhooks

@WebhookAPI @Negative @P1
Scenario: Fetch webhooks without token
  When I send a GET request without Authorization header
  Then I should get 401 Unauthorized

@WebhookAPI @Negative @P2
Scenario: Fetch webhooks for an invalid service/environment
  When I hit the endpoint for wrong service
  Then I should get 404 Not Found or empty array

@WebhookAPI @Positive @P1
Scenario: Successfully delete an existing webhook
  Given a webhook exists with matching serviceName and URL
  When I send a DELETE request with valid token and correct body
  Then I should get 200 OK or 204 No Content

@WebhookAPI @Negative @P1
Scenario: Delete webhook without Authorization
  When I send a DELETE request without the token
  Then I should get 401 Unauthorized

@WebhookAPI @Negative @P2
Scenario: Delete non-existent webhook
  When I send a DELETE request for a webhook that doesn't exist
  Then I should get 404 Not Found or suitable message
