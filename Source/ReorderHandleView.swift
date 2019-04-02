//
//  ReorderHandleView.swift
//  SwiftReorder
//
//  Created by Colin Humber on 2017-03-16.
//  Copyright © 2017 Adam Shin. All rights reserved.
//

import UIKit

public class ReorderHandleView: UIView {
    fileprivate let reorderHandleImageView = UIImageView()

    var reorderHandleImage: UIImage? {
        set {
            reorderHandleImageView.image = newValue
        }
        
        get {
            return reorderHandleImageView.image
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        reorderHandleImageView.contentMode = .center
        addSubview(reorderHandleImageView)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 46, height: UIView.noIntrinsicMetric)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        reorderHandleImageView.frame = bounds
    }
    
    // block all touch events on the reorder control so that the initial tap on the control on the cell
    // won't pass the touch event to the table view causing the cell to be highlighted, but will still
    // allow the long press gesture attached to the cell to begin reordering will still fire
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
