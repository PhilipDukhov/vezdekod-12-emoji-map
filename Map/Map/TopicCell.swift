//
//  TopicCell.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import UIKit

class TopicCell: UICollectionViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var topicLabel: UILabel!
    @IBOutlet private var moodView: MoodView!
        
    var dimmed = false {
        didSet {
            contentView.alpha = dimmed ? 0.4 : 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moodView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        moodView.layer.shadowOpacity = 1
        moodView.layer.shadowRadius = 4
        moodView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    var topic: Topic? {
        didSet {
            titleLabel.text = topic?.title
            topicLabel.text = topic?.emoji
            moodView.text = topic?.mood.emoji
        }
    }
}
