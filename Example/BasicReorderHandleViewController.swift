//
// Copyright (c) 2016 Adam Shin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

class BasicReorderHandleViewController: UITableViewController {
    
    var items = ["File",
                 "File",
                 "Comment 1",
                 "Comment 2",
                 "Comment 3",
                 "File",
                 "Comment 4",
                 "File",
                 "File",
                 "Comment 5"]
    var reorderItems: [String]?
    
    var colors: [String: UIColor] = ["File": UIColor.lightGray]
    
    //    var items = (1...10).map { "Item \($0)" }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(style: .plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basic"

        tableView.separatorStyle = .none
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.reorder.delegate = self
//        tableView.reorder.useReorderHandles = true
    }
    
}

extension BasicReorderHandleViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        var sourceRow: IndexPath?
        var reordering = false
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        switch tableView.reorder.reorderState {
        case let .preparing(s):
            sourceRow = s
            print("preparing row \(s.row)")
            
        case let .reordering(_, _, _):
            reordering = true
            
        default:
            break
        }

        let itemsToUse: [String]! = reordering ? reorderItems : items

        let text = items[indexPath.row]
        cell.label.text = text
//        cell.showsCustomReorderControl = true
        cell.label.backgroundColor = .clear
        cell.backgroundColor = colors[text]

        if text == "File" {
            cell.showBubble = false
        }
        else if text.hasPrefix("Comment") {
            cell.showBubble = true
            
            var afterBubbleCell = false
            var beforeBubbleCell = false
            
//            if let sourceRow = sourceRow, reordering {
//                if sourceRow.row == indexPath.row - 1 {
//                    var x = true
//                }
//            }
            
            if indexPath.row > 0 {
                afterBubbleCell = itemsToUse[indexPath.row - 1].hasPrefix("Comment")
            }
            
            if indexPath.row < items.count - 1 {
                beforeBubbleCell = itemsToUse[indexPath.row + 1].hasPrefix("Comment")
            }
            
            let topOffset: CGFloat = afterBubbleCell ? 5 : 17
            let bottomOffset: CGFloat = beforeBubbleCell ? 7 : 19

            if indexPath == sourceRow {
                cell.topPadding = 12
                cell.bottomPadding = 12
            }
            else {
                cell.topPadding = topOffset
                cell.bottomPadding = bottomOffset
            }
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 60
        
        var reordering = false
        var sourceRow: IndexPath?
        var destinationRow: IndexPath?
        switch tableView.reorder.reorderState {
        case let .reordering(r, d, _):
            reordering = true
            sourceRow = r
            destinationRow = d
            break

        default: break
        }

        let itemsToUse: [String]! = reordering ? reorderItems : items
        
        let text = itemsToUse[indexPath.row]
        
        if text == "File" {
            height = 60
        }
        else {
            var afterBubbleCell = false
            var beforeBubbleCell = false
            
            let baseCommentHeight: CGFloat = 36
        
            if indexPath.row > 0 {
                afterBubbleCell = itemsToUse[indexPath.row - 1].hasPrefix("Comment")
            }
            
            if indexPath.row < items.count - 1 {
                beforeBubbleCell = itemsToUse[indexPath.row + 1].hasPrefix("Comment")
            }
            
            let topOffset: CGFloat = afterBubbleCell ? 5 : 17
            let bottomOffset: CGFloat = beforeBubbleCell ? 7 : 19
            
            height = baseCommentHeight + topOffset + bottomOffset
        }
        
        switch tableView.reorder.reorderState {
        case let .reordering(sourceRow, _, _):
            print("reordering row \(sourceRow.row)")
            break
            
        case let .preparing(sourceRow) where indexPath.row == sourceRow.row && itemsToUse[sourceRow.row].hasPrefix("Comment"):
            height = 60
            break
            
        default:
            break
        }
        
        return height
    }
}

extension BasicReorderHandleViewController: TableViewReorderDelegate {
    
    func tableViewDidBeginReordering(_ tableView: UITableView) {
        reorderItems = items
    }
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, offsetYFor sourceIndexPath: IndexPath) -> CGFloat {
        return 5
    }
}
