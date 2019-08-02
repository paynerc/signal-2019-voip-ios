//
//  OverlayWindow.swift
//  VoiceDialerSDK
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import UIKit

class OverlayWindow: UIWindow {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.clear
        windowLevel = .statusBar - 1

        rootViewController = UIViewController()
    }
}
