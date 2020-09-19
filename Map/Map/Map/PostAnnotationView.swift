//
//  PostAnnotationView.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import UIKit
import MapKit

class PostAnnotationView: MKAnnotationView {
    private let moodView = MoodView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addSubview(moodView)
        moodView.setShadow(true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let annotation = annotation as? PostAnnotation else { return }
        setupAnnotation(post: annotation.post)
    }
    
    private func setupAnnotation(post: Post) {
        moodView.text = post.topic.emoji
        let side = min(UIScreen.main.bounds.width * 0.95 / 3.93185165258,
                       32 + CGFloat(post.clusterCount) * 10)
        
        moodView.frame = .init(origin: .zero, size: CGSize(width: side, height: side))
        frame = moodView.frame
    }
}
