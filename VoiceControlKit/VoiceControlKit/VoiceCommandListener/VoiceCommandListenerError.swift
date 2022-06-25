//
//  VoiceCommandListenerError.swift
//  VoiceControlKit
//
//  Created by Ahmed Abdelkarim on 25/06/2022.
//

import Foundation

public enum VoiceCommandListenerError: LocalizedError {
    case nilRecognizer
    case recognizerIsUnavailable
    case notAuthorized_denied
    case notAuthorized_restricted
    case notAuthorized_notDetermined
    case notPermittedToRecord
    
    public var errorDescription: String? {
        switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer."
            case .recognizerIsUnavailable: return "Recognizer is unavailable. Make sure Siri is enabled from Settings."
            case .notAuthorized_denied: return "Not authorized to recognize speech. User denied access to speech recognition."
            case .notAuthorized_restricted: return "Not authorized to recognize speech. Speech recognition restricted on this device."
            case .notAuthorized_notDetermined: return "Not authorized to recognize speech. Speech recognition not yet authorized."
            case .notPermittedToRecord: return "Not permitted to record audio. User denied access to Microphone."
        }
    }
}
