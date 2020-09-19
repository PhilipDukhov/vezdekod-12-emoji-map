//
//  CircleView.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import UIKit

class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}
