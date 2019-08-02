//
//  ViewController.swift
//  VoiceDialerSDKTester
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import UIKit
import VoiceDialerSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .portrait
        }
    }

    @IBAction func placeCall(_ sender: Any) {
        VoiceDialer.placeCall(identity: "ACME Support",
                              accessToken: "ACCESS_TOKEN",
                              callParameters: ["to" : "some_number"],
                              delegate: self)
    }
}

extension ViewController: VoiceDialerDelegate {
    func callStateDidChange(state: CallState, error: Error?) {
        print("callStateDidChange: \(state.rawValue), error: \(error != nil ? error!.localizedDescription : "N/A")")
    }

    func callDidFailToConnect(error: Error) {
        print("callDidFailToConnect: \(error.localizedDescription)")
    }

    func callWillHangup() {
        print("Hangup button pressed")
    }

    func callWillMute() {
        print("Mute button pressed")
    }

    func callWillUmute() {
        print("Unmute button pressed")
    }

    func callWillHold() {
        print("Hold button pressed")
    }

    func callWillResume() {
        print("Unhold button pressed")
    }
}
