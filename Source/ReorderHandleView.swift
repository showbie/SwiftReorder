//
//  ReorderHandleView.swift
//  SwiftReorder
//
//  Created by Colin Humber on 2017-03-16.
//  Copyright © 2017 Adam Shin. All rights reserved.
//

import UIKit

class ReorderHandleView: UIView {

    init() {
        super.init(frame: .zero)
        
        backgroundColor = .red
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: UIViewNoIntrinsicMetric)
    }
}
