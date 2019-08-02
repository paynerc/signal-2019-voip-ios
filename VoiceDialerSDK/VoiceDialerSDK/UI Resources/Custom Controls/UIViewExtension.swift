//
//  UIViewExtension.swift
//  VoiceDialerSDK
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import UIKit

extension UIView {

    func makeRound() {
        self.layer.cornerRadius = self.bounds.size.width / 2
    }
}
