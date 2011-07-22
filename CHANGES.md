## 0.7.0
* Much improved Xcode 4 support.
* Generate Xcode 4 style archives using the :xcode4_archive_mode
* Xcode 4 style archives appear in Xcode organiser complete with your release notes.
* Added a :skip_clean option to skip cleaning when building
* Allow the app name to be explicitly set using :app_name
* WARNING: Xcode 3 support is officially deprecated as of this release!

## 0.6.0
* Support Xcode 4 workspaces and schemes.

## 0.5.0
* Support configurable path to xcodebuild executable
* Support configurable path to Xcode project file

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
