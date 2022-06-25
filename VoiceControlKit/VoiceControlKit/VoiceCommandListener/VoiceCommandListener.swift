//
//  VoiceCommandListener.swift
//  VoiceControlKit
//
//  Created by Ahmed Abdelkarim on 25/06/2022.
//

import Foundation
import AVFoundation
import Speech

public class VoiceCommandListener {
    // MARK: - Singleton
    private static var instance: VoiceCommandListener?
    public static var shared: VoiceCommandListener {
        get {
            if(instance == nil) {
                instance = VoiceCommandListener()
            }
            
            return instance!
        }
    }
    
    private init() {
        recognizer = SFSpeechRecognizer()
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Properties
    public weak var delegate: VoiceCommandListenerDelegate?
    
    /// Accepts first recognized command regardless confidence value. This option makes detection very fast compared to waiting high confidence recognitions, but may not be accurate sometimes.
    public var acceptsFirstRecognition: Bool = true
    
    /// The minimum confidence to accept voice command.
    public var minimumAcceptableConfidence: Float = 0.8
    
    /// Use only device offline recognition, and don't send voice over network for online recognition services. Offline recognition supports specific languages only, and won’t be as accurate as online services.
    public var onDeviceRecognitionOnly: Bool = true
    
    // MARK: - Private Properties
    private var recognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    
    private var singleWordCommandsDictionary: [String : VoiceCommand]?
    private var sentenceCommandsDictionary: [String : VoiceCommand]?
    
    private var choosingFirstRecognition = false
    
    // MARK: - Methods
    public func start(with commands: [VoiceCommand], success: @escaping () -> Void, failure: @escaping (VoiceCommandListenerError) -> Void) {
        
        stop()
        populateCommandsDictionary(with: commands)
        
        requestPermission(success: {
            DispatchQueue(label: "Speech Recognizer Queue", qos: .background).async { [weak self] in
                guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                    failure(.recognizerIsUnavailable)
                    return
                }
                
                do {
                    let (audioEngine, request) = try self.prepareEngine()
                    self.audioEngine = audioEngine
                    self.request = request
                    self.task = recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
                    success()
                }
                catch {
                    self.reset()
                    failure(.notPermittedToRecord)
                }
            }
        }, failure: { error in
            failure(error)
        })
    }
    
    public func stop() {
        reset()
    }
    
    // MARK: - Private Methods
    private func populateCommandsDictionary(with commands: [VoiceCommand]) {
        singleWordCommandsDictionary = [String : VoiceCommand]()
        sentenceCommandsDictionary = [String : VoiceCommand]()
        
        for command in commands {
            let commandText = command.text.lowercased()
            
            if commandText.contains(" ") { // has more than 1 word
                sentenceCommandsDictionary?[commandText] = command
            }
            else { // has 1 word
                singleWordCommandsDictionary?[commandText] = command
            }
        }
    }
    
    private func requestPermission(success: @escaping () -> Void, failure: @escaping (VoiceCommandListenerError) -> Void) {
        guard recognizer != nil else {
            failure(.nilRecognizer)
            return
        }
        
        SFSpeechRecognizer.requestAuthorization { authorizationStatus in
            switch authorizationStatus {
                case .authorized:
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        if granted {
                            success()
                        }
                        else {
                            failure(.notPermittedToRecord)
                        }
                    }
                case .denied:
                    failure(.notAuthorized_denied)
                case .restricted:
                    failure(.notAuthorized_restricted)
                case .notDetermined:
                    failure(.notAuthorized_notDetermined)
                @unknown default:
                    fatalError("Unknown authorization status")
            }
        }
    }
    
    private func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = self.onDeviceRecognitionOnly
        
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        DispatchQueue.global().async {
            let receivedFinalResult = result?.isFinal ?? false
            let receivedError = error != nil
            
            if receivedFinalResult || receivedError {
                //print("stopped -> final result: \(receivedFinalResult) , error: \(receivedError)")
                
                if receivedError && result == nil {
                    self.task?.cancel()
                    return
                }
                
                // restart to extend a new recognition period (~1 minute)
                do {
                    let (audioEngine, request) = try self.prepareEngine()
                    self.audioEngine = audioEngine
                    self.request = request
                    self.task = self.recognizer!.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
                } catch {
                    print("couldn't restart")
                }
            }
            else if let result = result {
                self.processRecognitionResult(result)
            }
        }
    }
    
    private func processRecognitionResult(_ result: SFSpeechRecognitionResult) {
        let bestTranscription = result.bestTranscription
        
        guard let lastSegment = bestTranscription.segments.last
        else {
            return
        }
        
        let lastWord = lastSegment.substring.lowercased()
        let confidence = lastSegment.confidence
        
        // check for word
        if let command = singleWordCommandsDictionary?[lastWord] {
            callDelegate(for: command, withConfidence: confidence)
        }
        
        // check for sentences
        let bestTranscriptionText = bestTranscription.formattedString.lowercased()
        //print("transcript: \(bestTranscriptionText)\nconfidence: \(confidence)")
        lookForSentences(in: bestTranscriptionText, withConfidence: confidence)
    }
    
    private func callDelegate(for command: VoiceCommand, withConfidence confidence: Float) {
        if onDeviceRecognitionOnly {
            if acceptsFirstRecognition {
                if confidence == 0 {
                    delegate?.voiceCommandListener(self, detected: command)
                }
            }
            else {
                if confidence < minimumAcceptableConfidence {
                    return
                }
                
                delegate?.voiceCommandListener(self, detected: command)
            }
        }
        else {
            if acceptsFirstRecognition { // needs more testing and improvement
                if !choosingFirstRecognition {
                    choosingFirstRecognition = true
                    
                    delegate?.voiceCommandListener(self, detected: command)
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
                        self?.choosingFirstRecognition = false
                    }
                }
            }
            else {
                if confidence < minimumAcceptableConfidence {
                    return
                }
                
                delegate?.voiceCommandListener(self, detected: command)
            }
        }
    }
    
    private func lookForSentences(in transcription: String, withConfidence confidence: Float) {
        guard let sentenceCommandsDictionary = self.sentenceCommandsDictionary else {
            return
        }
        
        let keys = [String](sentenceCommandsDictionary.keys)
        
        if onDeviceRecognitionOnly {
            if acceptsFirstRecognition {
                if confidence == 0 {
                    for key in keys {
                        if transcription.hasSuffix(key) {
                            if let command = sentenceCommandsDictionary[key] {
                                delegate?.voiceCommandListener(self, detected: command)
                            }
                        }
                    }
                }
            }
            else {
                if confidence < minimumAcceptableConfidence {
                    return
                }
                
                for key in keys {
                    if transcription.hasSuffix(key) {
                        if let command = sentenceCommandsDictionary[key] {
                            delegate?.voiceCommandListener(self, detected: command)
                        }
                    }
                }
            }
        }
        else {
            if acceptsFirstRecognition { // needs more testing and improvement
                if !choosingFirstRecognition {
                    choosingFirstRecognition = true
                    
                    for key in keys {
                        if transcription.hasSuffix(key) {
                            if let command = sentenceCommandsDictionary[key] {
                                delegate?.voiceCommandListener(self, detected: command)
                            }
                        }
                    }
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
                        self?.choosingFirstRecognition = false
                    }
                }
            }
            else {
                if confidence < minimumAcceptableConfidence {
                    return
                }
                
                for key in keys {
                    if transcription.hasSuffix(key) {
                        if let command = sentenceCommandsDictionary[key] {
                            delegate?.voiceCommandListener(self, detected: command)
                        }
                    }
                }
            }
        }
    }
    
    private func reset() {
        let inputNode = audioEngine?.inputNode
        inputNode?.removeTap(onBus: 0)
        inputNode?.reset()
        
        audioEngine?.stop()
        audioEngine = nil
        
        request?.endAudio()
        request = nil
        
        task?.cancel()
        task = nil
        
        singleWordCommandsDictionary = nil
        sentenceCommandsDictionary = nil
    }
}
