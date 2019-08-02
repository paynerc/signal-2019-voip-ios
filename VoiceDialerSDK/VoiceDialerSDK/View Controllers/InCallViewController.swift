//
//  InCallViewController.swift
//  VoiceDialerSDK
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import UIKit

class InCallViewController: UIViewController {

    @IBOutlet weak var contactImageContainer: UIView!
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var muteButton: RoundButton!
    @IBOutlet weak var hangupButton: RoundButton!

    // MARK: - Instance properties
    weak var callController: CallController?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize.init(width: 2, height: 2)
        view.layer.shadowRadius = 3.5
        view.layer.shadowOpacity = 0.4

        contactImageContainer.makeRound()

        if let callController = callController {
            identityLabel.text = callController.identity

            muteButton.isSelected = callController.isMuted
        }

        let recognizerDoubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        recognizerDoubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(recognizerDoubleTap)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .portrait
        }
    }

    @IBAction func muteButtonPressed(_ sender: Any) {
        guard let callController = callController else {
            return
        }

        callController.isMuted = !callController.isMuted
        muteButton.isSelected = callController.isMuted
    }

    @IBAction func hangupButtonPressed(_ sender: Any) {
        guard let callController = callController else {
            return
        }

        callController.hangupCall()
    }

    @objc func doubleTap() {
        guard let callController = callController else {
            return
        }

        callController.displayDialerView()
    }
}
