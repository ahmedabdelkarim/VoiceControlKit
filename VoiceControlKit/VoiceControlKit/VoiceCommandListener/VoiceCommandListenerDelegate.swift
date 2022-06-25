//
//  VoiceCommandListenerDelegate.swift
//  VoiceControlKit
//
//  Created by Ahmed Abdelkarim on 25/06/2022.
//

import Foundation

public protocol VoiceCommandListenerDelegate: AnyObject {
    func voiceCommandListener(_ listener: VoiceCommandListener, detected command: VoiceCommand)
}
