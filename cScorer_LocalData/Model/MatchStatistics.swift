//
//  MatchScore.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 25.11.20.
//

import Foundation

class MatchStatistics {
    
    var chairUmpireOnCourtTimeStamp: NSDate = NSDate()
    var warmupStartedTimeStamp: NSDate = NSDate()
    var warmupFinishedTimeStamp: NSDate = NSDate()
    var matchStartedTimeStamp: NSDate = NSDate()
    var matchFinishedTimeStamp: NSDate = NSDate()
    var timePlayed: NSDate = NSDate()
    
    var chairUmpireOnCourt: Bool = false
    var wonToss: Int = 0
    var madeChoice: Int = 0
    var isServer: Int = 0
    var onLeftSide: Int = 0
    
}
