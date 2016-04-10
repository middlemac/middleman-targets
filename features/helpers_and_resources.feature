Feature: Provide helpers and resource items to make multiple targets easy to manage.

  As a software developer
  I want to use helpers and resource items
  In order to deploy different versions of my project
  
  Scenario: Build with the default target
    Given a built app at "middleman_targets_app"
    When I cd to "custom_build_dir (pro)"
    And the file "index.html" should contain "Insult: NO"
    And the file "index.html" should contain "TargetName: pro"
    And the file "index.html" should contain "TargetFree: NO"
    And the file "index.html" should contain "TargetValueForSampleKey: You are a valued contributor to our balance sheet!"
    And the file "index.html" should contain "CurrentPageValidFeatures: [:grants_wishes]"
    And the file "index.html" should contain 'src="/pro-root.png"'
    And the file "index.html" should contain 'src="/all-root-logo.png"'
    And the file "index.html" should contain 'src="/images/pro-image.png"'
    And the file "index.html" should contain 'src="/images/all-logo.png"'

  Scenario: Build with --target pro
    Given a built app at "middleman_targets_app" with flags "--target pro"
    When I cd to "custom_build_dir (pro)"
    And the file "index.html" should contain "Insult: NO"
    And the file "index.html" should contain "TargetName: pro"
    And the file "index.html" should contain "TargetFree: NO"
    And the file "index.html" should contain "TargetValueForSampleKey: You are a valued contributor to our balance sheet!"
    And the file "index.html" should contain "CurrentPageValidFeatures: [:grants_wishes]"
    And the file "index.html" should contain 'src="/pro-root.png"'
    And the file "index.html" should contain 'src="/all-root-logo.png"'
    And the file "index.html" should contain 'src="/images/pro-image.png"'
    And the file "index.html" should contain 'src="/images/all-logo.png"'

  Scenario: Build with --target free
    Given a built app at "middleman_targets_app" with flags "--target free"
    When I cd to "free_build (free)"
    And the file "index.html" should contain "Insult: YES"
    And the file "index.html" should contain "TargetName: free"
    And the file "index.html" should contain "TargetFree: YES"
    And the file "index.html" should contain "TargetValueForSampleKey: People who use free versions don't drive profits."
    And the file "index.html" should contain "CurrentPageValidFeatures: [:feature_advertise_pro, :insults_user]"
    And the file "index.html" should contain 'src="/free-root.png"'
    And the file "index.html" should contain 'src="/all-root-logo.png"'
    And the file "index.html" should contain 'src="/images/free-image.png"'
    And the file "index.html" should contain 'src="/images/all-logo.png"'
