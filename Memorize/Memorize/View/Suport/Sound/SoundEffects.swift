//  Support/Sound/SoundEffects.swift

import AVFoundation

@MainActor
final class SoundEffects {
    enum Effect: CaseIterable { case match, mismatch }

    static let shared = SoundEffects()

    // Bank of URLs discovered in the bundle
    private var bank: [Effect: [URL]] = [:]

    // One reusable player per URL (reduces churn & “overload” logs)
    private var players: [URL: AVAudioPlayer] = [:]

    private init() {
        setupAudioSession()
        bank[.match] = discover(prefix: "sfx_match")
        bank[.mismatch] = discover(prefix: "sfx_mismatch")
        preloadPlayers()
    }

    // MARK: - Public

    func play(_ effect: Effect) {
        guard let url = chooseURL(for: effect) else { return }
        guard let player = players[url] else { return }
        if player.isPlaying { player.stop() }
        player.currentTime = 0
        player.volume = 1.0
        player.play()
        #if DEBUG
            print("SFX ▶︎ \(effect) → \(url.lastPathComponent)")
        #endif
    }

    #if DEBUG
        func debugInventory() {
            for e in Effect.allCases {
                let files = (bank[e] ?? []).map(\.lastPathComponent)
                print(
                    "SFX inventory [\(e)]:",
                    files.isEmpty ? "— none —" : files.joined(separator: ", ")
                )
            }
        }
    #endif

    // MARK: - Private

    private func setupAudioSession() {
        // Choose .playback if you want sound even with the mute switch ON.
        // .ambient respects the mute switch.
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            try session.setActive(true)
        } catch {
            #if DEBUG
                print("SFX audio session error:", error)
            #endif
        }
    }

    private func discover(prefix: String) -> [URL] {
        let exts = ["mp3", "m4a", "wav"]
        // Find any file whose name starts with the prefix (case-insensitive)
        var urls: [URL] = []
        for ext in exts {
            let found =
                Bundle.main.urls(
                    forResourcesWithExtension: ext,
                    subdirectory: nil
                ) ?? []
            urls.append(
                contentsOf: found.filter {
                    $0.lastPathComponent.lowercased().hasPrefix(
                        prefix.lowercased()
                    )
                }
            )
        }
        // Deduplicate & sort for stable randomness
        return Array(Set(urls)).sorted {
            $0.lastPathComponent < $1.lastPathComponent
        }
    }

    private func preloadPlayers() {
        for (_, files) in bank {
            for url in files where players[url] == nil {
                if let p = try? AVAudioPlayer(contentsOf: url) {
                    p.prepareToPlay()
                    players[url] = p
                }
            }
        }
    }

    private func chooseURL(for effect: Effect) -> URL? {
        guard let files = bank[effect], !files.isEmpty else { return nil }
        if effect == .mismatch { return files.randomElement() }
        return files.first
    }
}
