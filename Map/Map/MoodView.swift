//
//  MoodView.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import UIKit

class MoodView: CircleView {
    private let label = UILabel()
    var mood: Mood! {
        didSet {
            label.text = mood.emoji
        }
    }
    var bordered = true {
        didSet {
            updateBorder()
        }
    }
    
    init(mood: Mood) {
        super.init(frame: .init(origin: .zero, size: .init(width: 32, height: 32)))
        self.mood = mood
        label.text = mood.emoji
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = .white
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.baselineAdjustment = .alignCenters
        label.font = .systemFont(ofSize: 33)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 2),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        borderColor = UIColor.black.withAlphaComponent(0.05)
        updateBorder()
        
        setShadow(true)
    }
    
    private func updateBorder() {
        borderWidth = bordered ? 0.5 : 0
    }
}
