//
//  UITableViewCell+CustomReorderHandles.swift
//  SwiftReorder
//
//  Created by Colin Humber on 2017-03-16.
//  Copyright © 2017 Adam Shin. All rights reserved.
//

import UIKit

@objc
extension UITableViewCell {
    private struct AssociatedKeys {
        static var showsCustomReorderControl: UInt8 = 0
        static var handlesView: UInt8 = 1
    }
    
    /// An object that manages drag-and-drop reordering of table view cells.
    open var showsCustomReorderControl: Bool {
        set {
            if newValue != showsCustomReorderControl {
                objc_setAssociatedObject(self, &AssociatedKeys.showsCustomReorderControl, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
                if newValue {
                    let handlesView = ReorderHandleView()
                    handlesView.translatesAutoresizingMaskIntoConstraints = false

                    addSubview(handlesView)

                    NSLayoutConstraint.activate([
                        handlesView.trailingAnchor.constraint(equalTo: trailingAnchor),
                        handlesView.topAnchor.constraint(equalTo: topAnchor),
                        handlesView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    ])
                    
                    reorderHandlesView = handlesView
                }
                else {
                    reorderHandlesView?.removeFromSuperview()
                    reorderHandlesView = nil
                }
            }
            
            if newValue {
                NotificationCenter.default.addObserver(self, selector: #selector(reorderEnabledStateDidChange(_:)), name: ReorderController.ReorderingEnabledStateChangedNotification, object: nil)
            }
            else {
                NotificationCenter.default.removeObserver(self, name: ReorderController.ReorderingEnabledStateChangedNotification, object: nil)
            }
        }
        
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.showsCustomReorderControl) as? NSNumber)?.boolValue ?? false
        }
    }
    
    public private(set) var reorderHandlesView: ReorderHandleView? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.handlesView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.handlesView) as? ReorderHandleView
        }
    }

    public var reorderHandleImage: UIImage? {
        set {
            reorderHandlesView?.reorderHandleImage = newValue
        }
        
        get {
            return reorderHandlesView?.reorderHandleImage
        }
    }
    
    public func setReorderHandleViewEnabled(_ isEnabled: Bool, animated: Bool = true) {
        let animations = {
            self.reorderHandlesView?.isUserInteractionEnabled = isEnabled
            self.reorderHandlesView?.alpha = isEnabled ? 1 : 0.33
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, animations: animations)
        }
        else {
            animations()
        }
    }
    
    @objc private func reorderEnabledStateDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let isEnabled = userInfo[ReorderController.ReorderingEnabledStateKey] as? Bool else { return }
        
        setReorderHandleViewEnabled(isEnabled)
    }
}
