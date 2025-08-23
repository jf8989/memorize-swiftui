//  Support/Sound/SoundEffects.swift

import AVFoundation
import SwiftUI

/// Tiny SFX helper for short, overlapping sounds (mp3).
/// - Category: `.ambient` so it respects the mute switch and mixes with other audio.
@MainActor
final class SoundEffects {
    static let shared = SoundEffects()

    enum Effect: String, CaseIterable {
        case match = "sfx_match"  // sfx_match.mp3
        case mismatch = "sfx_mismatch"  // sfx_mismatch.mp3
    }

    private var players: [Effect: AVAudioPlayer] = [:]

    private init() {
        configureAudioSession()
        preload()
    }

    // MARK: - Public

    func play(_ effect: Effect) {
        if let p = players[effect] {
            if p.isPlaying { p.currentTime = 0 }  // fast retrigger
            p.play()
        } else {
            // Late load fallback (shouldn’t happen after preload)
            load(effect)?.play()
        }
    }

    // MARK: - Private

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: [.mixWithOthers])
        try? session.setActive(true, options: [])
    }

    private func preload() {
        Effect.allCases.forEach { _ = load($0) }
    }

    @discardableResult
    private func load(_ effect: Effect) -> AVAudioPlayer? {
        guard
            let url = Bundle.main.url(
                forResource: effect.rawValue,
                withExtension: "mp3"
            )
        else { return nil }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[effect] = player
            return player
        } catch {
            return nil
        }
    }
}
