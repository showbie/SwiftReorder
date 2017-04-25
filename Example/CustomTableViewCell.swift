//
//  CustomTableViewCell.swift
//  SwiftReorder
//
//  Created by Colin Humber on 2017-04-18.
//  Copyright © 2017 Adam Shin. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    let bubbleView = UIView()
    let label = UILabel()
    var labelText = "" {
        didSet {
            label.text = labelText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var showBubble = true {
        didSet {
            bubbleView.isHidden = !showBubble
            
            labelBubbleConstraint.isActive = showBubble
            labelContentViewConstraint.isActive = !showBubble
            setNeedsLayout()
        }
    }
    
    var topPadding: CGFloat = 12 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    var bottomPadding: CGFloat = 12 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    var topConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    var labelBubbleConstraint: NSLayoutConstraint!
    var labelContentViewConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        bubbleView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        bubbleView.layer.cornerRadius = 18
        
        contentView.addSubview(bubbleView)
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        topConstraint = bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topPadding)
        bottomConstraint = bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bottomPadding)
    
        topConstraint.isActive = true
        bottomConstraint.isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 100).isActive = true
        labelBubbleConstraint = label.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor)
        labelContentViewConstraint = label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        label.text = "\(labelText)                        \(frame.size.height)"
//        label.sizeToFit()
//        label.center.y = showBubble ? bubbleView.center.y : contentView.center.y
//        label.frame.origin.x = 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        topConstraint.constant = topPadding
        bottomConstraint.constant = -bottomPadding
        
        super.updateConstraints()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
