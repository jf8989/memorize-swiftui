//  Extensions/Date+Utils.swift

import Foundation

/// Small date/time conveniences.
extension Date {
    /// Seconds elapsed since `other` (or 0 if `other` is nil).
    func seconds(since other: Date?) -> Int {
        guard let other else { return 0 }
        return Int(self.timeIntervalSince(other))
    }
}
