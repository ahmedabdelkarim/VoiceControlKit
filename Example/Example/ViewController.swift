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
            VoiceCommand(text: "Hi"),
            VoiceCommand(text: "How are you"),
        ]
        
        VoiceCommandListener.shared.delegate = self
        
        VoiceCommandListener.shared.start(with: commands, success: {
            
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

