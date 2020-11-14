//
//  NotificationExtension.swift
//  cScorer_LocalData
//
//  Created by Lukas Schauer on 14.11.20.
//

import Foundation

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}
