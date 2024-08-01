//
//  AudioRecognizerView.swift
//  AudioRecognizer
//
//  Created by Kanta Oikawa on 7/11/24.
//

import AVFoundation
import SwiftUI

struct AudioRecognizerView: View {
    @State private var viewModel = AudioRecognizerViewModel()

    var body: some View {
        VStack {
            Text(viewModel.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            HStack {
                Button(viewModel.isRecording ? "End" : "Start") {
                    viewModel.onRecordButtonTapped()
                }
                .disabled(viewModel.authStatus != .authorized)
                .containerRelativeFrame(
                    .horizontal,
                    count: 2,
                    span: 1,
                    spacing: 0
                )

                Button("Play") {
                    viewModel.playNotificationSound()
                }
                .containerRelativeFrame(
                    .horizontal,
                    count: 2,
                    span: 1,
                    spacing: 0
                )
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    AudioRecognizerView()
}
