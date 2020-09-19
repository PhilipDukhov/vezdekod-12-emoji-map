//
//  CurrentMoodView.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import UIKit

class CurrentMoodView: UIView {
    var title = "" {
        didSet {
            label.text = title
        }
    }
    
    var moodView: MoodView? {
        didSet {
            guard oldValue != moodView else { return }
            oldValue?.update(onCurrent: false)
            moodView?.update(onCurrent: true)
            if let moodView = moodView {
                moodViewConstraints = [
                    label.leftAnchor.constraint(equalTo: moodView.centerXAnchor, constant: 16),
                    moodView.centerYAnchor.constraint(equalTo: centerYAnchor),
                    moodView.widthAnchor.constraint(equalToConstant: moodView.bounds.width),
                    moodView.heightAnchor.constraint(equalToConstant: moodView.bounds.height),
                ]
            } else {
                moodViewConstraints = []
            }
        }
    }
    
    private var moodViewConstraints = [NSLayoutConstraint]() {
        didSet {
            oldValue.forEach { $0.isActive = false }
            moodViewConstraints.forEach { $0.isActive = true }
        }
    }
    
    private let label = UILabel()
    init() {
        super.init(frame: .init(x: 0, y: 0, width: 201, height: 36))
        backgroundColor = .white
        setShadow(true)
        cornerRadius = 10
        label.font = .systemFont(ofSize: 14)
        let icon = UIImageView(image: Asset.Images.dropdownArrow.image)
        [label,
         icon,]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                addSubview($0)
            }
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 36),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.rightAnchor.constraint(equalTo: icon.leftAnchor, constant: -6),
            icon.rightAnchor.constraint(equalTo: rightAnchor, constant: -14),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1),
            heightAnchor.constraint(equalToConstant: 36),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MoodView {
    func update(onCurrent: Bool) {
        translatesAutoresizingMaskIntoConstraints = !onCurrent
        bordered = !onCurrent
        setShadow(!onCurrent)
    }
}
