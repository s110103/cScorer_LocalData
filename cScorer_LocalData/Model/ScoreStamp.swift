//
//  Score.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 19.05.21.
//

import Foundation

class ScoreStamp {
    
    var timeStamp: NSDate = NSDate()
    var currentSet: Int = 0
    var firstTeamCurrentGameScore: Int = 0
    var secondTeamCurrentGameScore: Int = 0
    
    var firstTeamCurrentInGameScore: Int = 0
    var secondTeamCurrentInGameScore: Int = 0
    
    var firstTeamCurrentTiebreakScore: Int = 0
    var secondTeamCurrentTiebreakScore: Int = 0
    
    init() {
    }
    
}
