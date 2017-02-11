# Milestone 3A: iOS Unit Test Info
iOS code is located in the `app` directory.
We have written unit tests for our model classes, network calls, and location services.
To test network calls and getting location info, we had to create mock classes. The ability to mock classes for testing is not built into Swift, but we found this useful tutorial: [Mocking Classes You Don't Own](http://masilotti.com/testing-nsurlsession-input/)

Navigate to `Graffiti/GraffitiTests`.
For Milestone 3A, refer to
* **ApiTests.swift**, which uses
    * MockRequest.swift
    * MockSessionManager.swift
* **LocationServiceTests.swift**, which uses
    * MockLocationManager.swift
* **PostTest.swift**
* **UserTests.swift**
