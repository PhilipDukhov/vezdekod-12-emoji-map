//
//  UIView+InspectableLayer.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import UIKit

extension UIView {
    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get { layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : nil }
    }
    @IBInspectable var cornerRadius: CGFloat {
        set { layer.cornerRadius = newValue }
        get { layer.cornerRadius }
    }
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { layer.borderWidth }
    }
    
    func setShadow(_ visible: Bool) {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        layer.shadowOpacity = visible ? 1 : 0
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}
