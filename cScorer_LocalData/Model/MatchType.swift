//
//  MatchType.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 21.11.20.
//

import Foundation

class MatchType {
    
    var matchType: Int = 0
    var template: Int = 0
    var totalSets: Int = 1
    var gamesInSet: Int = 6
    var twoGameDifference: Bool = true
    var noAd: Bool = false
    var heatRule: Bool = false
    
    var advantageSet: Int = 0
    
    var tiebreakAt: Int = 6
    var tiebreakPoints: Int = 7
    var lastSetTiebreakPoints: Int = 7
    var matchTiebreakPoints: Int = 10
    var matchTiebreak: Bool = false
    
    init(_matchType: Int, _template: Int, _totalSets: Int, _gamesInSet: Int, _twoGameDifference: Bool, _noAd: Bool, _heatRule: Bool, _advantageSet: Int, _tiebreakAt: Int, _tiebreakPoints: Int, _lastSetTiebreakPoints: Int, _matchTiebreakPoints: Int, _matchTiebreak: Bool) {
        matchType = _matchType
        template = _template
        totalSets = _totalSets
        gamesInSet = _gamesInSet
        twoGameDifference = _twoGameDifference
        noAd = _noAd
        heatRule = _heatRule
        
        advantageSet = _advantageSet
        
        tiebreakAt = _tiebreakAt
        tiebreakPoints = _tiebreakPoints
        lastSetTiebreakPoints = _lastSetTiebreakPoints
        matchTiebreakPoints = _matchTiebreakPoints
        matchTiebreak = _matchTiebreak
    }
    
    init() {
    }
    
}
