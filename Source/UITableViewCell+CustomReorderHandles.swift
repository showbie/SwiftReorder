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
}
