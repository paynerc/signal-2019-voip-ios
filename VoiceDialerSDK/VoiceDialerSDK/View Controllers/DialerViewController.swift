//
//  DialerViewController.swift
//  VoiceDialerSDK
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import UIKit

class DialerViewController: UIViewController {

    @IBOutlet weak var contactImageContainer: UIView!
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var muteButton: RoundButton!
    @IBOutlet weak var keypadButton: RoundButton!
    @IBOutlet weak var speakerButton: RoundButton!
    @IBOutlet weak var holdButton: RoundButton!
    @IBOutlet weak var hangupButton: RoundButton!

    // MARK: - Instance properties
    weak var callController: CallController?

    var callState: CallState = .Connecting {
        didSet {
            switch callState {
            case .Connecting:
                stateLabel.text = "Connecting..."
            case .Ringing:
                stateLabel.text = "Ringing..."
            case .Connected:
                stateLabel.text = "Connected..."
                muteButton.isEnabled = true
                // keypadButton.isEnabled = true
                speakerButton.isEnabled = true
                holdButton.isEnabled = true
            case .Reconnecting:
                stateLabel.text = "Reconnecting..."
                muteButton.isEnabled = false
                keypadButton.isEnabled = false
                speakerButton.isEnabled = false
                holdButton.isEnabled = false
            case .Disconnected:
                stateLabel.text = "Disconnected..."
                muteButton.isEnabled = false
                keypadButton.isEnabled = false
                speakerButton.isEnabled = false
                holdButton.isEnabled = false
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .portrait
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contactImageContainer.makeRound()
        muteButton.isEnabled = false
        keypadButton.isEnabled = false
        speakerButton.isEnabled = false
        holdButton.isEnabled = false

        if let callController = callController {
            callState = callController.callState
            identityLabel.text = callController.identity

            // Set button states as necessary
            muteButton.isSelected = callController.isMuted
            holdButton.isSelected = callController.isOnHold
            speakerButton.isSelected = callController.isOnSpeaker
        }

        let recognizerDoubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        recognizerDoubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(recognizerDoubleTap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIDevice.current.isProximityMonitoringEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = false

        super.viewWillDisappear(animated)
    }

    func displayError(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.callController?.cleanupUI()
        }
        alert.addAction(okAction)

        self.present(alert, animated: true)
    }

    @IBAction func muteButtonPressed(_ sender: Any) {
        guard let callController = callController else {
            return
        }

        callController.isMuted = !callController.isMuted
        muteButton.isSelected = callController.isMuted
    }

    @IBAction func keypadButtonPressed(_ sender: Any) {
        print("Keypad button pressed!")
    }

    @IBAction func speakerButtonPressed(_ sender: Any) {
        guard let callController = callController else {
            return
        }

        callController.isOnSpeaker = !callController.isOnSpeaker
        speakerButton.isSelected = callController.isOnSpeaker
    }

    @IBAction func holdButtonPressed(_ sender: Any) {
        guard let callController = callController else {
            return
        }

        callController.isOnHold = !callController.isOnHold
        holdButton.isSelected = callController.isOnHold
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

        if callState == .Connected {
            callController.displayInCallView()
        }
    }
}
