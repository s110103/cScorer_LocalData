//
//  Match.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 21.11.20.
//

import Foundation

class Match {
    
    var firstTeamFirstPlayer: String
    var firstTeamFirstPlayerSurname: String
    var firstTeamSecondPlayer: String
    var firstTeamSecondPlayerSurname: String
    var secondTeamFirstPlayer: String
    var secondTeamFirstPlayerSurname: String
    var secondTeamSecondPlayer: String
    var secondTeamSecondPlayerSurname: String
    var firstTeamFirstPlayerDetails: String
    var firstTeamSecondPlayerDetails: String
    var secondTeamFirstPlayerDetails: String
    var secondTeamSecondPlayerDetails: String
    var matchService: Int
    var court: String
    var matchType: MatchType?
    var tournamendData: TournamentData?
    
    init(_firstTeamFirstPlayer: String, _firstTeamFirstPlayerSurname: String, _firstTeamSecondPlayer: String, _firstTeamSecondPlayerSurname: String, _secondTeamFirstPlayer: String, _secondTeamFirstPlayerSurname: String, _secondTeamSecondPlayer: String, _secondTeamSecondPlayerSurname: String, _firstTeamFirstPlayerDetails: String, _firstTeamSecondPlayerDetails: String, _secondTeamFirstPlayerDetails: String, _secondTeamSecondPlayerDetails: String, _matchService: Int, _court: String) {
        firstTeamFirstPlayer = _firstTeamFirstPlayer
        firstTeamFirstPlayerSurname = _firstTeamFirstPlayerSurname
        firstTeamSecondPlayer = _firstTeamSecondPlayer
        firstTeamSecondPlayerSurname = _firstTeamSecondPlayerSurname
        secondTeamFirstPlayer = _secondTeamFirstPlayer
        secondTeamFirstPlayerSurname = _secondTeamFirstPlayerSurname
        secondTeamSecondPlayer = _secondTeamSecondPlayer
        secondTeamSecondPlayerSurname = _secondTeamSecondPlayerSurname
        firstTeamFirstPlayerDetails = _firstTeamFirstPlayerDetails
        firstTeamSecondPlayerDetails = _firstTeamSecondPlayerDetails
        secondTeamFirstPlayerDetails = _secondTeamFirstPlayerDetails
        secondTeamSecondPlayerDetails = _secondTeamSecondPlayerDetails
        matchService = _matchService
        court = _court
        
        let _matchType: MatchType = MatchType(_matchType: 0, _totalSets: 2, _gamesInSet: 6, _twoGameDifference: true, _noAd: false, _heatRule: false, _advantageSet: 0, _tiebreakAt: 6, _tiebreakPoints: 7, _lastSetTiebreakPoints: 7, _matchTiebreak: false)
        let _tournamentData: TournamentData = TournamentData(_tournamentName: "", _tournamentPlace: "", _tournamendStage: "", _tournamendCategory: "")
        
        matchType = _matchType
        tournamendData = _tournamentData
    }
    
}
