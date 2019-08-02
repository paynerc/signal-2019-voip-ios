//
//  CallState.swift
//  VoiceDialerSDK
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import Foundation

@objc public enum CallState: Int {
    case Connecting
    case Ringing
    case Connected
    case Reconnecting
    case Disconnected
}
