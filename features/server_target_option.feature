Feature: Run the preview server with various target options.

  As a software developer
  I want to start the preview server with different targets
  In order to view my changes immediately in the browser
  
  Background:
    Given a fixture app "middleman_targets_app"
    And the default aruba timeout is 30 seconds
    
  Scenario: Start the server with the default target (pro)
    When I run `middleman server` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    And the output should contain:
    """
    Middleman will serve using target "pro"
    """

  Scenario: Start the server with the --pro target
    When I run `middleman server --target pro` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    And the output should contain:
    """
    Middleman will serve using target "pro"
    """

  Scenario: Start the server with the --free target
    When I run `middleman server --target free` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    And the output should contain:
    """
    Middleman will serve using target "free"
    """
