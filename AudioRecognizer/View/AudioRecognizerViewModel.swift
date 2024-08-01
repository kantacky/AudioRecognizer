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
    @ObservationIgnored var speechRecognizer: SpeechRecognizer
    var authStatus: SFSpeechRecognizerAuthorizationStatus
    var isRecording: Bool
    var text: String
    @ObservationIgnored var soundID: SystemSoundID

    init() {
        speechRecognizer = SpeechRecognizer()
        authStatus = .notDetermined
        isRecording = false
        text = ""
        soundID = 0

        if let url = Bundle.main.url(forResource: "notification", withExtension: "m4a") {
            AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        }

        speechRecognizer.authStatusDidChange = { [weak self] status in
            self?.authStatus = status
        }

        speechRecognizer.resultDidChange = { [weak self] result in
            self?.text = result ?? ""
            if result == "こんにちは" {
                self?.playNotificationSound()
            }
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

    func playNotificationSound() {
        print("🎵")
        AudioServicesPlaySystemSound(soundID)
    }
}
