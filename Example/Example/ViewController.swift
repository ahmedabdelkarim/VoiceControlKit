//
//  ViewController.swift
//  Example
//
//  Created by Ahmed Abdelkarim on 25/06/2022.
//

import UIKit
import VoiceControlKit

class ViewController: UIViewController, VoiceCommandListenerDelegate {
    // MARK: - Outlets
    @IBOutlet weak var label: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let commands = [
            VoiceCommand(text: "Hello"),
            VoiceCommand(text: "Open next page"),
            VoiceCommand(text: "Take photo"),
            VoiceCommand(text: "Go back")
        ]
        
        VoiceCommandListener.shared.delegate = self
        
        VoiceCommandListener.shared.start(with: commands, success: {
            // Now it's listening to voice commands
        }, failure: { error in
            print(error.localizedDescription)
        })
    }
    
    // MARK: - VoiceCommandListenerDelegate
    func voiceCommandListener(_ listener: VoiceCommandListener, detected command: VoiceCommand) {
        
        // Do whatever you want depending on detected command
        
        DispatchQueue.main.async {
            self.label.text = command.text
        }
    }
}

