//
//  Match.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 21.11.20.
//

import Foundation

class Match {
    
    var firstTeamFirstPlayer: String = "Player"
    var firstTeamFirstPlayerSurname: String = "1"
    var firstTeamSecondPlayer: String = "Player"
    var firstTeamSecondPlayerSurname: String = "1.1"
    
    var secondTeamFirstPlayer: String = "Player"
    var secondTeamFirstPlayerSurname: String = "2"
    var secondTeamSecondPlayer: String = "Player"
    var secondTeamSecondPlayerSurname: String = "2.1"
    
    var firstTeamFirstPlayerDetails: Player = Player()
    var firstTeamSecondPlayerDetails: Player = Player()
    var secondTeamFirstPlayerDetails: Player = Player()
    var secondTeamSecondPlayerDetails: Player = Player()
    
    var court: String = "-"
    var syncedWithCloud: Bool = false
    
    var backToChairUmpireViewController: Bool = false
    var backToPlayersViewController: Bool = false
    var backToStartMatchViewController: Bool = false
    
    var matchType: MatchType = MatchType()
    var tournamendData: TournamentData = TournamentData()
    var matchStatistics: MatchStatistics = MatchStatistics()
    
    init(_firstTeamFirstPlayer: String, _firstTeamFirstPlayerSurname: String, _firstTeamSecondPlayer: String, _firstTeamSecondPlayerSurname: String, _secondTeamFirstPlayer: String, _secondTeamFirstPlayerSurname: String, _secondTeamSecondPlayer: String, _secondTeamSecondPlayerSurname: String, _firstTeamFirstPlayerDetails: Player, _firstTeamSecondPlayerDetails: Player, _secondTeamFirstPlayerDetails: Player, _secondTeamSecondPlayerDetails: Player, _court: String, _syncedWithCloud: Bool) {
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
        court = _court
        syncedWithCloud = _syncedWithCloud
        
        let _matchType: MatchType = MatchType(_matchType: 0, _template: 0, _templateBackup: 0, _totalSets: 2, _gamesInSet: 6, _twoGameDifference: true, _noAd: false, _heatRule: false, _ballChange: 0, _advantageSet: 0, _tiebreakAt: 6, _tiebreakPoints: 7, _lastSetTiebreakPoints: 7, _matchTiebreakPoints: 10, _matchTiebreak: false)
        let _tournamentData: TournamentData = TournamentData(_tournamentName: "", _tournamentPlace: "", _tournamendStage: "", _tournamendCategory: "")
        let _matchStatistics: MatchStatistics = MatchStatistics()
        
        matchType = _matchType
        tournamendData = _tournamentData
        matchStatistics = _matchStatistics
    }
    
    init() {
        let _matchType: MatchType = MatchType(_matchType: 0, _template: 0, _templateBackup: 0, _totalSets: 2, _gamesInSet: 6, _twoGameDifference: true, _noAd: false, _heatRule: false, _ballChange: 0, _advantageSet: 0, _tiebreakAt: 6, _tiebreakPoints: 7, _lastSetTiebreakPoints: 7, _matchTiebreakPoints: 10, _matchTiebreak: false)
        let _tournamentData: TournamentData = TournamentData(_tournamentName: "", _tournamentPlace: "", _tournamendStage: "", _tournamendCategory: "")
        let _matchStatistics: MatchStatistics = MatchStatistics()
        
        matchType = _matchType
        tournamendData = _tournamentData
        matchStatistics = _matchStatistics
    }
    
}
