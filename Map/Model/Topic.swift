//
//  Topic.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import Foundation

enum Topic: String, CaseIterable, Codable {
    case music
    case films
    case autumn
    case work
    case quarantine
    case it
    case car
    case humor
    case photo
    case art
    case food
    case scared
    case sad
    case angry
    case inspiration
    case inlove

    var mood: Mood {
        switch self {
        case .music, .films, .humor, .photo, .art, .inspiration:
            return .highEnergy
        case .autumn, .work:
            return .lowEnergy
        case .quarantine, .scared, .sad, .angry:
            return .negitive
        case .car, .it, .food, .inlove:
            return .positive
        }
    }
    
    var emoji: String {
        switch self {
        case .music:
            return "🎧"
        case .films:
            return "🎬"
        case .autumn:
            return "🍂"
        case .work:
            return "👔"
        case .quarantine:
            return "🦠"
        case .it:
            return "💻"
        case .car:
            return "🚗"
        case .humor:
            return "🎭"
        case .photo:
            return "📷"
        case .art:
            return "🎨"
        case .food:
            return "🍿"
        case .scared:
            return "😱"
        case .sad:
            return "😢"
        case .angry:
            return "😡"
        case .inspiration:
            return "🤩"
        case .inlove:
            return "😍"
        }
    }
    
    var title: String {
        switch self {
        case .music:
            return "Музыка"
        case .films:
            return "Кино"
        case .autumn:
            return "Осень"
        case .work:
            return "Работа"
        case .quarantine:
            return "Карантин"
        case .it:
            return "IT"
        case .car:
            return "Авто"
        case .humor:
            return "Комедия"
        case .photo:
            return "Фото"
        case .art:
            return "Исскуство"
        case .food:
            return "Еда"
        case .scared:
            return "Испуг"
        case .sad:
            return "Грусть"
        case .angry:
            return "Злость"
        case .inspiration:
            return "Вдохновение"
        case .inlove:
            return "Влюбленность"
        }
    }
    
//    
}
