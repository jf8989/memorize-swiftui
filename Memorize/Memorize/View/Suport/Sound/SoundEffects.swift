//  Support/Sound/SoundEffects.swift

import AVFoundation

@MainActor
final class SoundEffects {
    static let shared = SoundEffects()

    enum Effect: CaseIterable { case match, mismatch, launch }

    private var bank: [Effect: [URL]] = [:]
    private var players: [URL: AVAudioPlayer] = [:]
    private var lastURLForEffect: [Effect: URL] = [:]

    private init() {
        setupAudioSession()
        // ✅ Auto-discover all effects based on their prefix.
        for e in Effect.allCases {
            bank[e] = discover(prefix: prefix(for: e))
        }
        preloadPlayers()
        #if DEBUG
            debugInventory()
        #endif
    }

    func play(_ effect: Effect) {
        guard let url = chooseURL(for: effect), let player = players[url] else {
            return
        }
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
        let s = AVAudioSession.sharedInstance()
        do {
            try s.setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            try s.setActive(true)
        } catch { print("SFX audio session error:", error) }
    }

    private func discover(prefix: String) -> [URL] {
        let exts = ["mp3", "m4a", "wav", "aif", "aiff", "caf"]
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
        return Array(Set(urls)).sorted {
            $0.lastPathComponent < $1.lastPathComponent
        }
    }

    private func preloadPlayers() {
        for files in bank.values {
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
        if files.count == 1 { return files[0] }
        var candidates = files
        if let last = lastURLForEffect[effect] {
            candidates.removeAll { $0 == last }
        }
        let url = candidates.randomElement()!
        lastURLForEffect[effect] = url
        return url
    }

    // Effect → filename prefix
    private func prefix(for effect: Effect) -> String {
        switch effect {
        case .match: return "sfx_match"
        case .mismatch: return "sfx_mismatch"
        case .launch: return "sfx_launch"
        }
    }
}
