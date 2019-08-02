//
//  VoiceDialer.swift
//  VoiceDialerSDK
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import UIKit

@objc public class VoiceDialer: NSObject {

    // Singleton creator
    static let sharedInstance: VoiceDialer = {
        let instance = VoiceDialer()

        // Any other initialization as required...

        return instance
    }()

    // MARK: - Instance properties
    let overlayWindow: OverlayWindow = OverlayWindow(frame: UIScreen.main.bounds)
    var callController: CallController?

    @objc public class func placeCall(identity: String,
                                      accessToken: String,
                                      callParameters: [String : String],
                                      delegate: VoiceDialerDelegate?) {

        // If we don't have an active call, we can start one...
        if sharedInstance.callController != nil {
            print("Already in an active call...");
            return
        }

        let callController = CallController(identity: identity,
                                            accessToken: accessToken,
                                            callParameters: callParameters,
                                            delegate: delegate)

        callController.initiateCall()

        sharedInstance.callController = callController
    }

    @objc public class func hangupCall() {
        guard let callController = sharedInstance.callController else {
            return
        }

        callController.hangupCall()
    }

    func cleanupActiveCall() {
        callController = nil
        resetOverlayWindow()
    }

    private func resetOverlayWindow() {
        overlayWindow.frame = UIScreen.main.bounds
        overlayWindow.isHidden = true
    }

    class func storyboard() -> UIStoryboard {
        let frameworkBundle = Bundle(for: VoiceDialer.self)
        let storyboard = UIStoryboard(name: "Main", bundle: frameworkBundle)

        return storyboard
    }
}
