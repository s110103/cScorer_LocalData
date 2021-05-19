//
//  PlayerViolationView.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 19.05.21.
//

import UIKit

class PlayerViolationView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }

}
