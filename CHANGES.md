## 0.4.2
* Support configurable path to xcodebuild executable

## 0.4
* If the user has set the EDITOR environment variable, use it to obtain the TestFlight release notes.
* Bugfix: TestFlight API now returns a 201 Created response when successful.
* Bugfix: Handle spaces in build artefacts.
* Updated the default archived build location to match the newest Xcode archived build location.

## 0.3.2
* Fixed bug #2 (task fails when no testflight distribution list set)

## 0.3.1
* Separate the :deploy task into :prepare and :deploy tasks.

## 0.3
* Added support for distribution lists to the TestFlight deployment strategy

## 0.2.1
* Allow the namespace of generated tasks to be customised

## 0.2
* Introduced deployment strategies, allowing custom deployment methods
* Added support for deploying beta releases to TestFlightApp.com

## 0.1.2

* Allow custom hosts when using the SCP deployment task (simonjefford)

## 0.1.1
* Fixed missing dependency

## 0.1
* Initial Release
