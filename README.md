# facepaint-ios-objc

To learn more about the face paint in DeepAR SDK, see our article https://help.deepar.ai/en/articles/5608765-face-painting-effect-tutorial

To run the example
* Go to https://developer.deepar.ai, sign up, create the project and the iOS app, copy the license key and paste it to ViewController.m (instead of your_license_key_goes_here string)
* Download the SDK from https://developer.deepar.ai and copy the DeepAR.framework into the repository root folder
* In the project settings select quickstart-ios-swift under Targets and:
  * Frameworks, Libararies and Embedded content add DeepAR.framework with Embed & Sign option selected
  * Go to Build Phases and make sure DeepAR.framework is included in Link Binary With libraries and Embeded Frameworks sections

Run the project
