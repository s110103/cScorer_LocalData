//
//  MatchScore.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 25.11.20.
//

import Foundation

class MatchStatistics {
    
    var chairUmpireOnCourtTimeStamp: NSDate = NSDate()
    var playersOnCourtTimeStamp: NSDate = NSDate()
    var warmupStartedTimeStamp: NSDate = NSDate()
    var warmupFinishedTimeStamp: NSDate = NSDate()
    var matchStartedTimeStamp: NSDate = NSDate()
    var matchFinishedTimeStamp: NSDate = NSDate()
    var timePlayed: NSDate = NSDate()
    
    var matchService: Int = 0
    
    var chairUmpireOnCourt: Bool = false
    var playersOnCourt: Bool = false
    var wonToss: Int = 0
    var madeChoice: Int = 0
    var isServer: Int = 0
    var onLeftSide: Int = 0
    var matchInitiated: Bool = false
    var warmupTimerRunning: Bool = false
    
    var gmaesFirstSetFirstPlayer: Int = 0
    var tiebreakFirstSetFirstPlayer: Int = 0
    var gmaesSecondSetFirstPlayer: Int = 0
    var tiebreakSecondSetFirstPlayer: Int = 0
    var gmaesThirdSetFirstPlayer: Int = 0
    var tiebreakThirdSetFirstPlayer: Int = 0
    var gmaesFourthSetFirstPlayer: Int = 0
    var tiebreakFourthSetFirstPlayer: Int = 0
    var gmaesFifthSetFirstPlayer: Int = 0
    var tiebreakFifthSetFirstPlayer: Int = 0
    
    var gmaesFirstSetSecondPlayer: Int = 0
    var tiebreakFirstSetSecondPlayer: Int = 0
    var gmaesSecondSetSecondPlayer: Int = 0
    var tiebreakSecondSetSecondPlayer: Int = 0
    var gmaesThirdSetSecondPlayer: Int = 0
    var tiebreakThirdSetSecondPlayer: Int = 0
    var gmaesFourthSetSecondPlayer: Int = 0
    var tiebreakFourthSetSecondPlayer: Int = 0
    var gmaesFifthSetSecondPlayer: Int = 0
    var tiebreakFifthSetSecondPlayer: Int = 0
    
    var matchTiebreakFirstPlayer: Int = 0
    var matchTiebreakSecondPlayer: Int = 0
    
    var currentGameFirstPlayer: Int = 0
    var currentGameSecondPlayer: Int = 0
    var currentGame: String = "0:0"
    var currentSets: String = "0:0"
    
    var firstTeamFirstPlayerPosition: Int = 0
    var firstTeamSecondPlayerPosition: Int = 0
    var secondTeamFirstPlayerPosition: Int = 0
    var secondTeamSecondPlayerPosition: Int = 0
    
    init(_chairUmpireOnCourtTimeStamp: NSDate, _playersOnCourtTimeStamp: NSDate, _warmupStartedTimeStamp: NSDate, _warmupFinishedTimeStamp: NSDate, _matchStartedTimeStamp: NSDate, _matchFinishedTimeStamp: NSDate, _timePlayed: NSDate, _matchService: Int, _chairUmpireOnCourt: Bool, _playersOnCourt: Bool, _wonToss: Int, _madeChoice: Int, _isServer: Int, _onLeftSide: Int, _matchInitiated: Bool, _warmupTimerRunning: Bool, _firstTeamFirstPlayerPosition: Int) {
        
        chairUmpireOnCourtTimeStamp = _chairUmpireOnCourtTimeStamp
        playersOnCourtTimeStamp = _playersOnCourtTimeStamp
        warmupStartedTimeStamp = _warmupStartedTimeStamp
        warmupFinishedTimeStamp = _warmupFinishedTimeStamp
        matchStartedTimeStamp = _matchStartedTimeStamp
        matchFinishedTimeStamp = _matchFinishedTimeStamp
        timePlayed = _timePlayed
        
        matchService = _matchService
        
        chairUmpireOnCourt = _chairUmpireOnCourt
        playersOnCourt = _playersOnCourt
        wonToss = _wonToss
        madeChoice = _madeChoice
        isServer = _isServer
        onLeftSide = _onLeftSide
        matchInitiated = _matchInitiated
        warmupTimerRunning = _warmupTimerRunning
        
        firstTeamFirstPlayerPosition = _firstTeamFirstPlayerPosition
    }
    
    init() {
    }
    
}
