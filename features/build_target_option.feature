Feature: Build with various target options.

  As a software developer
  I want to build output with different targets
  In order to deploy different versions of my project
  
  Scenario: Build with the default target (pro)
    Given a fixture app "middleman_targets_app"
    When I run `middleman build` interactively
    And I stop middleman if the output contains:
    """
    Project built successfully.
    """
    Then the output should contain:
    """
    Middleman will build using target "pro".
    """

  Scenario: Build with --target pro
    Given a fixture app "middleman_targets_app"
    When I run `middleman build --target pro` interactively
    And I stop middleman if the output contains:
    """
    Project built successfully.
    """
    Then the output should contain:
    """
    Middleman will build using target "pro".
    """

  Scenario: Build with --target free
    Given a fixture app "middleman_targets_app"
    When I run `middleman build --target free` interactively
    And I stop middleman if the output contains:
    """
    Project built successfully.
    """
    Then the output should contain:
    """
    Middleman will build using target "free".
    """

