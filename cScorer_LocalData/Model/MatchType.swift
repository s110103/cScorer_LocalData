//
//  MatchType.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 21.11.20.
//

import Foundation

class MatchType {
    
    var matchType: Int
    var totalSets: Int
    var gamesInSet: Int
    var tiebreakAt: Int
    var twoGameDifference: Bool
    var noAd: Bool
    var tiebreakPoints: Int
    var lastSetTiebreakPoints: Int
    var matchTiebreak: Bool
    
    init(_matchType: Int, _totalSets: Int, _gamesInSet: Int, _tiebreakAt: Int, _twoGameDifference: Bool, _noAd: Bool, _tiebreakPoints: Int, _lastSetTiebreakPoints: Int, _matchTiebreak: Bool) {
        matchType = _matchType
        totalSets = _totalSets
        gamesInSet = _gamesInSet
        tiebreakAt = _tiebreakAt
        twoGameDifference = _twoGameDifference
        noAd = _noAd
        tiebreakPoints = _tiebreakPoints
        lastSetTiebreakPoints = _lastSetTiebreakPoints
        matchTiebreak = _matchTiebreak
    }
    
}
