//
//  Player.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 29.11.20.
//

import Foundation

class Player {
    
    var firstName: String = ""
    var surName: String = ""
    var abbreviation: String = ""
    var country: String = ""
    var tennisClub: String = ""
    var gender: Int = 0
    var storingKey: String = ""
    
    init(_firstName: String, _surName: String, _abbreviation: String, _country: String, _tennisClub: String, _gender: Int) {
        firstName = _firstName
        surName = _surName
        abbreviation = _abbreviation
        country = _country
        tennisClub = _tennisClub
        gender = _gender
        
        storingKey = "randomKey"
    }
    
    init() {
        storingKey = "randomKey"
    }
    
}
