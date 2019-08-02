//
//  RoundButton.swift
//  VoiceDialerSDK
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import UIKit

// TODO:
// - Make @IBDesignable
// - Add properties and mark as @IBInspectable for
//     gap
//     imageOnTop
//     selectedButtonColor
//     unselectedButtonColor ?

class RoundButton: UIButton {
    override func awakeFromNib() {
        makeRound()
        centerImageAndText(gap: 5.0, imageOnTop: true)
    }

    override var bounds: CGRect {
        didSet {
            makeRound()
            centerImageAndText(gap: 5.0, imageOnTop: true)
        }
    }

    override var isSelected: Bool {
        didSet {
            self.backgroundColor = (isSelected == true ? UIColor.Buttons.Selected : UIColor.Buttons.Unselected)
        }
    }

    // TODO: While this generally works, it doesn't quite do exactly what I want. I would like all the text for all the
    //       buttons to be aligned. I think we need to do a bit more work in here with the maths to make it so that it
    //       behaves consistently across all the buttons.
    private func centerImageAndText(gap: CGFloat, imageOnTop: Bool) {
        guard let imageView = self.imageView,
            let titleLabel = self.titleLabel,
            let _ = titleLabel.text else { return }

        let sign: CGFloat = imageOnTop ? 1 : -1
        let imageSize = imageView.frame.size
        self.titleEdgeInsets = UIEdgeInsets(top: (imageSize.height + gap) * sign, left: -imageSize.width, bottom: 0, right: 0)

        let titleSize = titleLabel.bounds.size;
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + gap) * sign, left: 0, bottom: 0, right: -titleSize.width)
    }
}
