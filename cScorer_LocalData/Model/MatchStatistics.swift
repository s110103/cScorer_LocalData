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
    var warmupTimeInterval: TimeInterval = TimeInterval()
    var matchStartedTimeStamp: NSDate = NSDate()
    var matchRestartTimeStamp: NSDate = NSDate()
    var matchFinishedTimeStamp: NSDate = NSDate()
    var matchTimeInterval: TimeInterval = TimeInterval()
    var timePlayed: NSDate = NSDate()
    var matchInterruptedTimeStamp: NSDate = NSDate()
    var matchInterruptedTimeInterval: TimeInterval = TimeInterval()
    
    var matchRunning: Bool = false
    var matchSuspended: Bool = false
    var matchInterrupted: Bool = false
    var matchFinished: Bool = false
    var matchSuspensionReason: String = ""
    var matchInterruptionReason: String = ""
    
    var matchService: Int = 0
    
    var chairUmpireOnCourt: Bool = false
    var playersOnCourt: Bool = false
    var wonToss: Int = 0
    var madeChoice: Int = 0
    var isServer: String = ""
    var isServerAfterTiebreak: String = ""
    var onLeftSide: String = ""
    var onRightSide: String = ""
    var firstTeamNear: String = ""
    var firstTeamFar: String = ""
    var secondTeamNear: String = ""
    var secondTeamFar: String = ""
    var matchInitiated: Bool = false
    var warmupTimerRunning: Bool = false
    var gamesRemainingTillSwitch: Int = 1
    var pointsRemainingTillSwitch: Int = 6
    
    var justTiebreakPointsFirstPlayer: Int = 0
    
    var gamesFirstSetFirstPlayer: Int = 0
    var tiebreakFirstSetFirstPlayer: Int = 0
    var gamesSecondSetFirstPlayer: Int = 0
    var tiebreakSecondSetFirstPlayer: Int = 0
    var gamesThirdSetFirstPlayer: Int = 0
    var tiebreakThirdSetFirstPlayer: Int = 0
    var gamesFourthSetFirstPlayer: Int = 0
    var tiebreakFourthSetFirstPlayer: Int = 0
    var gamesFifthSetFirstPlayer: Int = 0
    var tiebreakFifthSetFirstPlayer: Int = 0
    
    var justTiebreakPointsSecondPlayer: Int = 0
    
    var gamesFirstSetSecondPlayer: Int = 0
    var tiebreakFirstSetSecondPlayer: Int = 0
    var gamesSecondSetSecondPlayer: Int = 0
    var tiebreakSecondSetSecondPlayer: Int = 0
    var gamesThirdSetSecondPlayer: Int = 0
    var tiebreakThirdSetSecondPlayer: Int = 0
    var gamesFourthSetSecondPlayer: Int = 0
    var tiebreakFourthSetSecondPlayer: Int = 0
    var gamesFifthSetSecondPlayer: Int = 0
    var tiebreakFifthSetSecondPlayer: Int = 0
    
    var matchTiebreakFirstPlayer: Int = 0
    var matchTiebreakSecondPlayer: Int = 0
    
    var currentGameFirstPlayer: Int = 0
    var currentGameSecondPlayer: Int = 0
    var currentGameInteger: Int = 0
    var currentGame: String = "0:0"
    var currentSets: String = "0:0"
    var currentSetPlayed: Int = 1
    var totalGamesPlayed: Int = 0
    var totalOverrules: Int = 0
    var currentFirstPosition: String = ""
    var currentSecondPosition: String = ""
    var currentLeftNear: String = ""
    var currentLeftFar: String = ""
    var currentRightNear: String = ""
    var currentRightFar: String = ""
    var firstFault: Bool = false
    var inTiebreak: Bool = false
    var matchTiebreak: Bool = false
    var winnerPhrase: String = ""
    
    var firstTeamFirstPlayerPosition: Int = 0
    var firstTeamSecondPlayerPosition: Int = 0
    var secondTeamFirstPlayerPosition: Int = 0
    var secondTeamSecondPlayerPosition: Int = 0
    
    var firstTeamFirstPlayerCodeViolations: Int = 0
    var firstTeamSecondPlayerCodeViolations: Int = 0
    var secondTeamFirstPlayerCodeViolations: Int = 0
    var secondTeamSecondPlayerCodeViolations: Int = 0
    
    var firstTeamFirstPlayerCodeViolationDescriptions: [Int] = []
    var firstTeamSecondPlayerCodeViolationDescriptions: [Int] = []
    var secondTeamFirstPlayerCodeViolationDescriptions: [Int] = []
    var secondTeamSecondPlayerCodeViolationDescriptions: [Int] = []
    
    var firstTeamFirstPlayerCodeViolationPenalties: [Int] = []
    var firstTeamSecondPlayerCodeViolationPenalties: [Int] = []
    var secondTeamFirstPlayerCodeViolationPenalties: [Int] = []
    var secondTeamSecondPlayerCodeViolationPenalties: [Int] = []
    
    var firstTeamFirstPlayerCodeViolationScoreStamps: [ScoreStamp] = []
    var firstTeamSecondPlayerCodeViolationScoreStamps: [ScoreStamp] = []
    var secondTeamFirstPlayerCodeViolationScoreStamps: [ScoreStamp] = []
    var secondTeamSecondPlayerCodeViolationScoreStamps: [ScoreStamp] = []
    
    var firstTeamFirstPlayerTimeViolations: Int = 0
    var firstTeamSecondPlayerTimeViolations: Int = 0
    var secondTeamFirstPlayerTimeViolations: Int = 0
    var secondTeamSecondPlayerTimeViolations: Int = 0
    
    var firstTeamFirstPlayerTimeViolationPenalties: [Int] = []
    var firstTeamSecondPlayerTimeViolationPenalties: [Int] = []
    var secondTeamFirstPlayerTimeViolationPenalties: [Int] = []
    var secondTeamSecondPlayerTimeViolationPenalties: [Int] = []
    
    var firstTeamFirstPlayerTimeViolationScoreStamps: [ScoreStamp] = []
    var firstTeamSecondPlayerTimeViolationScoreStamps: [ScoreStamp] = []
    var secondTeamFirstPlayerTimeViolationScoreStamps: [ScoreStamp] = []
    var secondTeamSecondPlayerTimeViolationScoreStamps: [ScoreStamp] = []
    
    var firstTeamFirstPlayerViolationLower: Bool = false
    var firstTeamSecondPlayerViolationLower: Bool = false
    var secondTeamFirstPlayerViolationLower: Bool = false
    var secondTeamSecondPlayerViolationLower: Bool = false
    
    var firstTeamFirstPlayerRemainingMedical: TimeInterval = 180
    var firstTeamSecondPlayerRemainingMedical: TimeInterval = 180
    var secondTeamFirstPlayerRemainingMedical: TimeInterval = 180
    var secondTeamSecondPlayerRemainingMedical: TimeInterval = 180
    
    var currentlyInMedical: String = ""
    
    init(_chairUmpireOnCourtTimeStamp: NSDate, _playersOnCourtTimeStamp: NSDate, _warmupStartedTimeStamp: NSDate, _warmupFinishedTimeStamp: NSDate, _warmupTimeInterval: TimeInterval, _matchStartedTimeStamp: NSDate, _matchFinishedTimeStamp: NSDate, _matchTimeInterval: TimeInterval, _timePlayed: NSDate, _matchService: Int, _chairUmpireOnCourt: Bool, _playersOnCourt: Bool, _wonToss: Int, _madeChoice: Int, _isServer: String, _onLeftSide: String, _onRightSide: String, _firstTeamNear: String, _firstTeamFar: String, _secondTeamNear: String, _secondTeamFar: String, _matchInitiated: Bool, _warmupTimerRunning: Bool, _firstTeamFirstPlayerPosition: Int) {
        
        chairUmpireOnCourtTimeStamp = _chairUmpireOnCourtTimeStamp
        playersOnCourtTimeStamp = _playersOnCourtTimeStamp
        warmupStartedTimeStamp = _warmupStartedTimeStamp
        warmupFinishedTimeStamp = _warmupFinishedTimeStamp
        warmupTimeInterval = _warmupTimeInterval
        matchStartedTimeStamp = _matchStartedTimeStamp
        matchFinishedTimeStamp = _matchFinishedTimeStamp
        matchTimeInterval = _matchTimeInterval
        timePlayed = _timePlayed
        
        matchService = _matchService
        
        chairUmpireOnCourt = _chairUmpireOnCourt
        playersOnCourt = _playersOnCourt
        wonToss = _wonToss
        madeChoice = _madeChoice
        isServer = _isServer
        onLeftSide = _onLeftSide
        onRightSide = _onRightSide
        firstTeamNear = _firstTeamNear
        firstTeamFar = _firstTeamNear
        secondTeamNear = _secondTeamNear
        secondTeamFar = _secondTeamFar
        matchInitiated = _matchInitiated
        warmupTimerRunning = _warmupTimerRunning
        
        firstTeamFirstPlayerPosition = _firstTeamFirstPlayerPosition
    }
    
    init() {
    }
    
}
