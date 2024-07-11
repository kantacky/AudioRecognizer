//
//  AudioRecognizerViewModel.swift
//  AudioRecognizer
//
//  Created by Kanta Oikawa on 7/11/24.
//

import Foundation
import Observation
import Speech

@Observable
class AudioRecognizerViewModel {
    var speechRecognizer: SpeechRecognizer
    var authStatus: SFSpeechRecognizerAuthorizationStatus
    var isRecording: Bool
    var text: String

    init() {
        speechRecognizer = SpeechRecognizer()
        authStatus = .notDetermined
        isRecording = false
        text = ""

        speechRecognizer.authStatusDidChange = { [weak self] status in
            self?.authStatus = status
        }

        speechRecognizer.resultDidChange = { [weak self] result in
            self?.text = result ?? ""
        }

        speechRecognizer.requestAuthorization()
    }

    func onRecordButtonTapped() {
        if isRecording {
            speechRecognizer.endRecording()
            isRecording = false
        } else {
            do {
                try speechRecognizer.startRecording()
                isRecording = true
            } catch {
                isRecording = false
            }
        }
    }
}
