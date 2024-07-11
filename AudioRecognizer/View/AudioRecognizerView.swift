//
//  AudioRecognizerView.swift
//  AudioRecognizer
//
//  Created by Kanta Oikawa on 7/11/24.
//

import SwiftUI

struct AudioRecognizerView: View {
    @State private var viewModel = AudioRecognizerViewModel()

    var body: some View {
        VStack {
            Text(viewModel.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button {
                viewModel.onRecordButtonTapped()
            } label: {
                if viewModel.isRecording {
                    Text("End")
                } else {
                    Text("Start")
                }
            }
            .disabled(viewModel.authStatus != .authorized)
        }
        .padding()
    }
}

#Preview {
    AudioRecognizerView()
}
