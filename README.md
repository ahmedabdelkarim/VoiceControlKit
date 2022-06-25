# VoiceControlKit
iOS framework that enables detecting and handling voice commands using microphone. Built using Swift with minumum target iOS 14.3.

# Features
* Detects commands of single word, and sentences ("Open", "Show first item details").
* Can work both online and offline, with extremely fast response time (< 0.5 second).
* Ability to use different set of commands for each screen.
* Works without Siri integration. So, users don't have to say "Hey Siri" to detect commands. It's a 100% free style detection.
* Very simple to configure and use.

# Prerequisites
* macOS Big Sur, or later
* Xcode 12.3+
* iPhone device with iOS 14.3+

# Install VoiceControlKit (using CocoaPods)
1. Make sure you have CocoaPods installed.
2. Update local pod repo using command **<em>pod repo update</em>** or **<em>pod repo update trunk</em>**.
3. Open Terminal from your project folder, and run commad **<em>pod init</em>**.
4. Add **<em>pod 'VoiceControlKit'</em>** inside Podfile, and run **<em>pod install</em>**.

# Configure iOS Project
1. Open **<em>Info.plist</em>** and add description for keys **<em>NSSpeechRecognitionUsageDescription</em>** and <em>**NSMicrophoneUsageDescription</em>**.
2. Use **VoiceCommandListener** and **VoiceCommandListenerDelegate** in your code (see below example) to detect and handle voice commands.
3. Test on a real iPhone device (not simulator).
4. Make sure Siri is enabled on iPhone device from Settings, Siri & Search, Listen for "Hey Siri".

# Code Example:

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
