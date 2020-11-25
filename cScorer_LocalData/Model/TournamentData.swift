//
//  TournamentData.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 21.11.20.
//

import Foundation

class TournamentData {
    
    var tournamentName: String
    var tournamentPlace: String
    var tournamentStage: String
    var tournamentCategory: String
    
    init(_tournamentName: String, _tournamentPlace: String, _tournamendStage: String, _tournamendCategory: String) {
        tournamentName = _tournamentName
        tournamentPlace = _tournamentPlace
        tournamentStage = _tournamendStage
        tournamentCategory = _tournamendCategory
    }
}
