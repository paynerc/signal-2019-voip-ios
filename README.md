# Signal 2019 Voice Demo - Mobile VoIP contextual Calling

This repository contains a project that demos Mobile VoIP contextual Calling. It is a fictitious online shopping application (hard coded PNG order form) with a dial button that places a call using the Twilio Voice SDK

The `VoiceDialerSDK.framework` and `VoiceDialerSDKTester.app` are written using Swift 5.0 and Xcode 10.2.

## Dependencies

The project uses Carthage to manage the `TwilioVoice.framework` dependency. After cloning this repository, run the `carthage bootstrap` command to fetch the `TwilioVoice.framework` dependency.

## Building

Before compiling the framework and application, be sure to replace the `ACCESS_TOKEN` place holder with a valid access token for your Twilio account. For more information, take a look at Twilio's [Access Token](https://www.twilio.com/docs/voice/voip-sdk/ios/get-started#access-tokens) documentation.