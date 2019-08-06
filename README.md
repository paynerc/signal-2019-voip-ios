# Signal 2019 Voice Demo - Mobile VoIP contextual Calling

This repository contains an iOS project, a call orchestrator, an access token generator, and a simple JS application that demonstrate Mobile VoIP contextual Calling. It is a fictitious online shopping application (hard coded PNG order form) that Alice uses to call Agent Bob regarding her order.

To set up this demo, you will need a [Twilio](https://twilio.com) account

## TwiML App & Call Orchestration
You can use [twiml-bin-call-orchestrator.xml](twiml-bin-call-orchestrator.xml) as your call orchestrator. Simply create a TwiML bin with contents and point your TwiML App to it

## Access Token
You will need an access token for Alice (Phone App) and for Agent Bob (JS Client). Use [twilio-function-access-token.js](twilio-function-access-token.js) as your access generator. Simply create a new Twilio Function and using a browser, enter the URL with the required params as specified in the file.

## Getting started with iOS App

The `VoiceDialerSDK.framework` and `VoiceDialerSDKTester.app` are written using Swift 5.0 and Xcode 10.2.

### Dependencies

The project uses Carthage to manage the `TwilioVoice.framework` dependency. After cloning this repository, run the `carthage bootstrap` command to fetch the `TwilioVoice.framework` dependency.

### Building

Before compiling the framework and application, be sure to replace the `ACCESS_TOKEN` place holder with a valid access token for your Twilio account. For more information, take a look at Twilio's [Access Token](https://www.twilio.com/docs/voice/voip-sdk/ios/get-started#access-tokens) documentation.

## Getting started with Agent Bob's JS App
Update [quickstart.js](JSClient/quickstart.js) with Agent Bob's access token and save the file. You will now need an http server to that serves Agent Bob's Application. When Agent Bob receives a call, it will show who is calling and the order they are calling about.

