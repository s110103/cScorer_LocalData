//
//  Match.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 21.11.20.
//

import Foundation

class Match {
    
    var firstTeamFirstPlayer: String = "Spieler"
    var firstTeamFirstPlayerSurname: String = "1"
    var firstTeamSecondPlayer: String = "Spieler"
    var firstTeamSecondPlayerSurname: String = "1.2"
    
    var secondTeamFirstPlayer: String = "Spieler"
    var secondTeamFirstPlayerSurname: String = "2"
    var secondTeamSecondPlayer: String = "Spieler"
    var secondTeamSecondPlayerSurname: String = "2.2"
    
    var firstTeamFirstPlayerDetails: Player = Player()
    var firstTeamSecondPlayerDetails: Player = Player()
    var secondTeamFirstPlayerDetails: Player = Player()
    var secondTeamSecondPlayerDetails: Player = Player()
    
    var matchService: Int = 0
    var court: String = "-"
    var matchType: MatchType?
    var tournamendData: TournamentData?
    
    init(_firstTeamFirstPlayer: String, _firstTeamFirstPlayerSurname: String, _firstTeamSecondPlayer: String, _firstTeamSecondPlayerSurname: String, _secondTeamFirstPlayer: String, _secondTeamFirstPlayerSurname: String, _secondTeamSecondPlayer: String, _secondTeamSecondPlayerSurname: String, _firstTeamFirstPlayerDetails: Player, _firstTeamSecondPlayerDetails: Player, _secondTeamFirstPlayerDetails: Player, _secondTeamSecondPlayerDetails: Player, _matchService: Int, _court: String) {
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
        
        let _matchType: MatchType = MatchType(_matchType: 0, _template: 0, _templateBackup: 0, _totalSets: 2, _gamesInSet: 6, _twoGameDifference: true, _noAd: false, _heatRule: false, _ballChange: 0, _advantageSet: 0, _tiebreakAt: 6, _tiebreakPoints: 7, _lastSetTiebreakPoints: 7, _matchTiebreakPoints: 10, _matchTiebreak: false)
        let _tournamentData: TournamentData = TournamentData(_tournamentName: "", _tournamentPlace: "", _tournamendStage: "", _tournamendCategory: "")
        
        matchType = _matchType
        tournamendData = _tournamentData
    }
    
    init() {
        let _matchType: MatchType = MatchType(_matchType: 0, _template: 0, _templateBackup: 0, _totalSets: 2, _gamesInSet: 6, _twoGameDifference: true, _noAd: false, _heatRule: false, _ballChange: 0, _advantageSet: 0, _tiebreakAt: 6, _tiebreakPoints: 7, _lastSetTiebreakPoints: 7, _matchTiebreakPoints: 10, _matchTiebreak: false)
        let _tournamentData: TournamentData = TournamentData(_tournamentName: "", _tournamentPlace: "", _tournamendStage: "", _tournamendCategory: "")
        
        matchType = _matchType
        tournamendData = _tournamentData
    }
    
}
