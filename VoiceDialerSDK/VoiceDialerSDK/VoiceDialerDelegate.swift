//
//  VoiceDialerDelegate.swift
//  VoiceDialerSDK
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import UIKit

@objc public protocol VoiceDialerDelegate: AnyObject {

    func callStateDidChange(state: CallState, error: Error?)

    func callDidFailToConnect(error: Error)

    func callWillHangup()

    func callWillMute()

    func callWillUmute()

    func callWillHold()

    func callWillResume()
}
