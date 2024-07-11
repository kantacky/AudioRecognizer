//
//  DataGenerator.swift
//  AudioRecognizer
//
//  Created by Kanta Oikawa on 7/11/24.
//

import Speech

class DataGenerator {
    static let data = SFCustomLanguageModelData(locale: Locale(identifier: "en_US"), identifier: "com.apple.SpokenWord", version: "1.0") {

        SFCustomLanguageModelData.PhraseCount(phrase: "Play the Albin counter gambit", count: 10)

        // Move Commands
        SFCustomLanguageModelData.PhraseCountsFromTemplates(classes: [
            "piece": ["pawn", "rook", "knight", "bishop", "queen", "king"],
            "royal": ["queen", "king"],
            "rank": Array(1...8).map({ String($0) })
        ]) {
            SFCustomLanguageModelData.TemplatePhraseCountGenerator.Template(
                "<piece> to <royal> <piece> <rank>",
                count: 10_000
            )
        }

        SFCustomLanguageModelData.CustomPronunciation(grapheme: "Winawer", phonemes: ["w I n aU @r"])
        SFCustomLanguageModelData.CustomPronunciation(grapheme: "Tartakower", phonemes: ["t A r t @ k aU @r"])

        SFCustomLanguageModelData.PhraseCount(phrase: "Play the Winawer variation", count: 10)
        SFCustomLanguageModelData.PhraseCount(phrase: "Play the Tartakower", count: 10)
    }

    static func export() async throws {
        try await data.export(to: URL(filePath: "customlm/en_US/CustomLMData.bin"))
    }
}
