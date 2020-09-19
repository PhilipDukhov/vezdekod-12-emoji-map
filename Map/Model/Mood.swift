//
//  Mood.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import Foundation

enum Mood: String, Codable, CaseIterable {
    case positive
    case negitive
    case highEnergy
    case lowEnergy
    
    var emoji: String {
        switch self {
        case .positive:
            return "😃"
        case .negitive:
            return "🙁"
        case .highEnergy:
            return "😜"
        case .lowEnergy:
            return "😴"
        }
    }
    
    var title: String {
        switch self {
        case .positive:
            return "Хорошее настроение"
        case .negitive:
            return "Плохое настроение"
        case .highEnergy:
            return "Высокая энергия"
        case .lowEnergy:
            return "Низкая энергия"
        }
    }
}
