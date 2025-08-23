//  Engine/GameTimePolicy.swift

import Foundation

enum GameTimeMode: String, Codable {
    case easy, medium, hard
}

struct GameTimeRules: Codable, Equatable {
    let perPairSeconds: Int
    let mismatchPenaltySeconds: Int
}

enum GameTimeRulesFactory {
    static func rules(for mode: GameTimeMode) -> GameTimeRules {
        switch mode {
        case .easy: return .init(perPairSeconds: 10, mismatchPenaltySeconds: 1)
        case .medium: return .init(perPairSeconds: 9, mismatchPenaltySeconds: 3)
        case .hard: return .init(perPairSeconds: 7, mismatchPenaltySeconds: 5)
        }
    }
}

enum GameTimeCalculator {
    /// Base time budget for a deck size (in pairs). Clamp to a tiny minimum so 2–3 pairs aren't zero.  
    static func baseTime(forPairs pairs: Int, rules: GameTimeRules) -> Int {
        let p = max(2, pairs)
        return max(5, p * rules.perPairSeconds)
    }
}
