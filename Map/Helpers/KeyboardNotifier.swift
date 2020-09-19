//
//  KeyboardNotifier.swift
//  Map
//
//  Created by Philip Dukhov on 9/19/20.
//

import UIKit

class KeyboardNotifier {
    var enabled: Bool = true { didSet { setNeedsUpdateConstraint(animationDuration: 0) } }
    
    init(parentView: UIView, constraint: NSLayoutConstraint, constant: CGFloat = 0, isAnchor: Bool) {
        self.parentView = parentView
        self.constraint = constraint
        self.constant = constant
        self.isAnchor = isAnchor
        
        constraint.constant = -constant
        notificationObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                                                      object: nil,
                                                                      queue: .main)
        { [weak self] in
            self?.keyboardEndFrame = ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            self?.setNeedsUpdateConstraint(animationDuration: UIView.inheritedAnimationDuration)
        }
    }
    
    private weak var parentView: UIView?
    private weak var constraint: NSLayoutConstraint?
    private var constant: CGFloat
    private let isAnchor: Bool
    private var keyboardEndFrame: CGRect?
    private var notificationObserver: NSObjectProtocol!
    
    private var latestAnimationDuration: TimeInterval? {
        didSet {
            guard oldValue == nil else { return }
            DispatchQueue.main.async {
                self.updateConstraint()
            }
        }
    }
    
    private func setNeedsUpdateConstraint(animationDuration: TimeInterval) {
        guard
            latestAnimationDuration == nil
                || animationDuration > latestAnimationDuration!
        else { return }
        latestAnimationDuration = animationDuration
    }
    
    private func updateConstraint() {
        defer {
            latestAnimationDuration = nil
        }
        guard
            let latestAnimationDuration = latestAnimationDuration,
            enabled,
            let endFrame = keyboardEndFrame,
            let parent = parentView,
            let bottomConstraint = constraint
        else { return }
        
        UIView.performWithoutAnimation {
            parent.layoutIfNeeded()
        }
        let sign: CGFloat = isAnchor ? -1 : 1
        let screenHeight = UIScreen.main.bounds.height
        if endFrame.minY >= screenHeight {
            let bottomInset = (isAnchor ? 0 : parent.safeAreaInsets.bottom) - constant
            bottomConstraint.constant = bottomInset
        } else {
            let bottomInset = (isAnchor ? parent.safeAreaInsets.bottom : 0) - constant
            bottomConstraint.constant = sign * (screenHeight - endFrame.minY - bottomInset)
        }
        
        UIView.animate(withDuration: latestAnimationDuration,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: { parent.layoutIfNeeded() },
                       completion: nil)
    }
}
