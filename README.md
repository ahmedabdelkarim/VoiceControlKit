# VoiceControlKit
iOS framework that enables detecting and handling voice commands using microphone. Built using Swift with minumum target iOS 14.3.

# Features
* Detects commands of single word, and sentences ("Open", "Show first item details").
* Can work both online and offline, with extremely fast response time (less than 0.5 second).
* Ability to use different set of commands for each screen.
* Works without Siri integration into your app.

# How to use?
1. Make sure you have CocoaPods installed.
2. Update local pod repo using command "pod repo update" or "pod repo update trunk".
3. Open Terminal from your project folder, and run commad "pod init".
4. Add pod 'VoiceControlKit' inside Podfile, and run "pod install".
5. Open Info.plist and add description for keys "NSSpeechRecognitionUsageDescription" and "NSMicrophoneUsageDescription".
6. Use VoiceCommandListener and VoiceCommandListenerDelegate in your code.
7. Test on a real iPhone device (not simulator).
8. Make sure Siri is enabled on device from Settings, Siri & Search, Listen for "Hey Siri".

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
