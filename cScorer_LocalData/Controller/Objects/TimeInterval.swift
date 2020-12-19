//
//  TimeInterval.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 19.12.20.
//

import Foundation

extension TimeInterval {
    func format(using units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: self)
    }
}
