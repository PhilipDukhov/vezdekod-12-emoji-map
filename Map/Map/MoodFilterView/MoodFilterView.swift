//
//  MoodFilterView.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import UIKit

class MoodFilterView: UIView {
    var selectedMood: Mood? {
        didSet {
            setNeedsLayout()
            selectedMoodChanged?(selectedMood)
        }
    }
    var selectedMoodChanged: ((Mood?) -> Void)?
    
    private let moodViews: [Mood: MoodView] = Mood.allCases.reduce(into: [:]) {
        let moodView = MoodView(mood: $1)
        $0[$1] = moodView
    }
    private let moodViewSize = CGSize(width: 32, height: 32)
    private let currentMoodView = CurrentMoodView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(currentMoodView)
        currentMoodView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentMoodView.centerXAnchor.constraint(equalTo: centerXAnchor),
            currentMoodView.topAnchor.constraint(equalTo: topAnchor)
        ])
        moodViews.values.forEach(addSubview)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if selectedMood == nil {
            return control(at: point) != nil
        }
        return currentMoodView.frame.contains(point)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let selectedMood = selectedMood {
            moodViews.forEach { mood, view in
                guard selectedMood == mood else {
                    view.frame = frame(for: mood, hidden: true)
                    return
                }
                currentMoodView.moodView = view
                currentMoodView.title = mood.title
                UIView.performWithoutAnimation {
                    currentMoodView.layoutIfNeeded()
                }
                currentMoodView.alpha = 1
            }
        } else {
            moodViews.forEach { mood, view in
                view.frame = frame(for: mood, hidden: false)
            }
            currentMoodView.moodView = nil
            currentMoodView.alpha = 0
        }
    }
    
    private func frame(for mood: Mood, hidden: Bool) -> CGRect {
        let sizeDiff = CGSize(width: (bounds.width - moodViewSize.width),
                              height: (bounds.height - moodViewSize.height))
        let offset: CGFloat = (hidden ? 100 : 0)
        let inset: CGFloat = 8
        let origin: CGPoint
        switch mood {
        case .positive:
            origin = .init(
                x: sizeDiff.width - inset + offset,
                y: sizeDiff.height / 2
            )
        case .negitive:
            origin = .init(
                x: inset - offset,
                y: sizeDiff.height / 2
            )
        case .highEnergy:
            origin = .init(
                x: sizeDiff.width / 2,
                y: 2 - offset
            )
        case .lowEnergy:
            origin = .init(
                x: sizeDiff.width / 2,
                y: sizeDiff.height - inset + offset
            )
        }
        return CGRect(origin: origin, size: moodViewSize)
    }
    
    @objc private func handleTap(_ gestureRecognozer: UITapGestureRecognizer) {
        if selectedMood == nil {
            selectedMood = control(at: gestureRecognozer.location(in: self))
        } else {
            selectedMood = nil
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    private func control(at point: CGPoint) -> Mood? {
        moodViews.first { $0.value.frame.controlOptimized.contains(point) }?.key
    }
}
