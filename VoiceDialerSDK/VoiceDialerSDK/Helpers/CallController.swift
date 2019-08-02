//
//  CallController.swift
//  VoiceDialerSDK
//
//  Created by Ryan C. Payne on 8/2/19.
//  Copyright © 2019 Ryan C. Payne. All rights reserved.
//

import UIKit
import TwilioVoice

class CallController: NSObject {

    let overlayWindow: OverlayWindow = OverlayWindow(frame: UIScreen.main.bounds)

    var identity: String
    var accessToken: String
    var callParameters: [String : String]
    var delegate: VoiceDialerDelegate?

    var isMuted: Bool {
        get {
            guard let call = call else {
                return false
            }
            return call.isMuted
        }
        set {
            isMuted == false ? delegate?.callWillMute() : delegate?.callWillUmute()
            call?.isMuted = newValue
        }
    }

    var isOnHold: Bool {
        get {
            guard let call = call else {
                return false
            }
            return call.isOnHold
        }
        set {
            isOnHold == false ? delegate?.callWillHold() : delegate?.callWillResume()
            call?.isOnHold = newValue
        }
    }

    var isOnSpeaker: Bool = false {
        didSet {
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(isOnSpeaker == true ? .speaker : .none)
            } catch {
            }
        }
    }

    var callState: CallState = .Connecting {
        didSet {
            if let dialerViewController = dialerViewController {
                dialerViewController.callState = callState
            }
        }
    }

    private var call: TVOCall?
    private var connectedAt: Date?
    private var timer: Timer?

    // View Controllers for the various views
    private var dialerViewController: DialerViewController?
    private var inCallViewController: InCallViewController?

    init(identity: String, accessToken: String, callParameters: [String : String], delegate: VoiceDialerDelegate?) {
        self.identity = identity
        self.accessToken = accessToken
        self.callParameters = callParameters
        self.delegate = delegate

        super.init()
    }

    func initiateCall() {
        displayDialerView()

        let connectOptions = TVOConnectOptions(accessToken: accessToken) { (builder) in
            builder.params = self.callParameters
        }

        call = TwilioVoice.connect(with: connectOptions, delegate: self)
    }

    func displayDialerView() {
        // If we don't have the dialer view, create it
        if dialerViewController == nil {
            dialerViewController = VoiceDialer.storyboard().instantiateViewController(withIdentifier: "DialerViewController") as? DialerViewController
        }

        if let dialerViewController = dialerViewController,
            let rootViewController = VoiceDialer.sharedInstance.overlayWindow.rootViewController {
            let overlayWindow = VoiceDialer.sharedInstance.overlayWindow

            dialerViewController.callController = self

            overlayWindow.frame = UIScreen.main.bounds
            VoiceDialer.sharedInstance.overlayWindow.makeKeyAndVisible()

            if rootViewController.presentedViewController != nil {
                rootViewController.presentedViewController?.dismiss(animated: true) {
                    self.inCallViewController = nil
                    rootViewController.present(dialerViewController, animated: true)
                }
            } else {
                rootViewController.present(dialerViewController, animated: true)
            }
        }
    }

    func displayInCallView() {
        // If we don't have the in call view, create it
        if inCallViewController == nil {
            inCallViewController = VoiceDialer.storyboard().instantiateViewController(withIdentifier: "InCallViewController") as? InCallViewController
        }

        if let inCallViewController = inCallViewController,
            let rootViewController = VoiceDialer.sharedInstance.overlayWindow.rootViewController {
            let overlayWindow = VoiceDialer.sharedInstance.overlayWindow

            inCallViewController.callController = self

            let width = UIScreen.main.bounds.width - 20
            inCallViewController.view.frame = CGRect(x: 0, y: 0, width: width, height: 100)
            let inCallWindowFrame = CGRect(x: 10, y: 40, width: width, height: 100)

            VoiceDialer.sharedInstance.overlayWindow.makeKeyAndVisible()

            if rootViewController.presentedViewController != nil {
                rootViewController.presentedViewController?.dismiss(animated: true) {
                    overlayWindow.frame = inCallWindowFrame
                    self.dialerViewController = nil
                    rootViewController.present(inCallViewController, animated: true)
                }
            } else {
                overlayWindow.frame = inCallWindowFrame
                rootViewController.present(inCallViewController, animated: true)
            }
        }
    }
    
    @objc func updateConnectionDuration() {
        if let connectedAt = connectedAt {
            let elapsed = Date().timeIntervalSince(connectedAt)
            let minutes = Int(elapsed) / 60 % 60
            let seconds = Int(elapsed) % 60

            let stringDuration = String(format:"%02i:%02i", minutes, seconds)

            if let dialerViewController = dialerViewController {
                if dialerViewController.isViewLoaded {
                    dialerViewController.stateLabel.text = stringDuration
                }
            }

            if let inCallViewController = inCallViewController {
                if inCallViewController.isViewLoaded {
                    inCallViewController.stateLabel.text = stringDuration
                }
            }
        }
    }

    // MARK: - Call Actions
    func hangupCall() {
        delegate?.callWillHangup()

        if let call = call,
            call.state != .disconnected {
            call.disconnect()
        } else {
            cleanupUI()
        }
    }

    func cleanupUI() {
        if let rootViewController = VoiceDialer.sharedInstance.overlayWindow.rootViewController {
            let overlayWindow = VoiceDialer.sharedInstance.overlayWindow
            // Reset the overlay window's frame so the animation works better
            overlayWindow.frame = UIScreen.main.bounds
            rootViewController.presentedViewController?.dismiss(animated: true, completion: {
                self.dialerViewController = nil
                self.inCallViewController = nil
                VoiceDialer.sharedInstance.cleanupActiveCall()
            })
        }
    }
}

extension CallController: TVOCallDelegate {
    func call(_ call: TVOCall, didFailToConnectWithError error: Error) {
        callState = .Disconnected

        if let dialerViewController = dialerViewController {
            dialerViewController.displayError(message: error.localizedDescription)
        }

        delegate?.callDidFailToConnect(error: error)
    }

    func callDidStartRinging(_ call: TVOCall) {
        callState = .Ringing

        delegate?.callStateDidChange(state: callState, error: nil)
    }

    func callDidConnect(_ call: TVOCall) {
        callState = .Connected
        connectedAt = Date()

        let timer = Timer(timeInterval: 1.0,
                          target: self,
                          selector: #selector(updateConnectionDuration),
                          userInfo: nil,
                          repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer

        delegate?.callStateDidChange(state: callState, error: nil)

        displayInCallView()
    }

    func call(_ call: TVOCall, isReconnectingWithError error: Error) {
        callState = .Reconnecting

        delegate?.callStateDidChange(state: callState, error: error)
    }

    func callDidReconnect(_ call: TVOCall) {
        callState = .Connected

        delegate?.callStateDidChange(state: callState, error: nil)
    }

    func call(_ call: TVOCall, didDisconnectWithError error: Error?) {
        callState = .Disconnected

        timer?.invalidate()
        timer = nil

        if let error = error {
            dialerViewController?.displayError(message: error.localizedDescription)
        }

        delegate?.callStateDidChange(state: callState, error: error)

        cleanupUI()
    }
}
