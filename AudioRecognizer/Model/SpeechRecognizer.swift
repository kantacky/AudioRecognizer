//
//  SpeechRecognizer.swift
//  AudioRecognizer
//
//  Created by Kanta Oikawa on 7/11/24.
//

import Speech

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    var authStatusDidChange: ((SFSpeechRecognizerAuthorizationStatus) -> Void)!
    var resultDidChange: ((String?) -> Void)!

    private var lmConfiguration: SFSpeechLanguageModel.Configuration {
        let outputDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dynamicLanguageModel = outputDir.appendingPathComponent("LM")
        let dynamicVocabulary = outputDir.appendingPathComponent("Vocab")
        return SFSpeechLanguageModel.Configuration(languageModel: dynamicLanguageModel, vocabulary: dynamicVocabulary)
    }

    override init() {
        super.init()
        speechRecognizer.delegate = self
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                self.authStatusDidChange(authStatus)
                switch authStatus {
                case .authorized:
                    Task.detached {
                        do {
                            try await DataGenerator.export()
                            // guard let assetPath = Bundle.main.path(forResource: "CustomLMData", ofType: "bin", inDirectory: "customlm/en_US") else {
                            //     return
                            // }
                            // let assetUrl = URL(fileURLWithPath: assetPath)
                            // try await SFSpeechLanguageModel.prepareCustomLanguageModel(
                            //     for: assetUrl,
                            //     clientIdentifier: "com.apple.SpokenWord",
                            //     configuration: self.lmConfiguration
                            // )
                        } catch {
                            NSLog("Failed to prepare custom LM: \(error.localizedDescription)")
                        }
                    }
                default:
                    break
                }
            }
        }
    }

    func startRecording() throws {

        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true

        // Keep speech recognition data on device
        recognitionRequest.customizedLanguageModel = self.lmConfiguration

        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false

            if let result = result {
                // Update the text view with the results.
                self.resultDidChange(result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func endRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}
