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

class BasicReorderHandleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    
    var items = ["File 1",
                 "File 2",
                 "Comment 1",
                 "Comment 2",
                 "Comment 3",
                 "File 3",
                 "Comment 4",
                 "File 4",
                 "File 5",
                 "Comment 5",
                 "File 6",
                 "Comment 6",
                 "File 7",
                 "File 8",
                 "Comment 7"]


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basic"

        let frame = self.view.frame.insetBy(dx: 0, dy: -50)
//        frame.size.height += 100
        
        tableView = UITableView(frame: frame, style: .plain)
        tableView.separatorStyle = .none
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.reorder.delegate = self
        tableView.reorder.cellOpacity = 0.5
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset.top = 50
        tableView.contentInset.bottom = 50
        view.addSubview(tableView)
//        tableView.reorder.useReorderHandles = true
    }
    
}

extension BasicReorderHandleViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

//        if case let .preparing(sourceRow) = tableView.reorder.reorderState {
//            sourceIndexPath = sourceRow
//        }

        let itemsToUse: [String]! = items

        let text = items[indexPath.row]
        cell.labelText = text
//        cell.showsCustomReorderControl = true
        cell.label.backgroundColor = .clear

        if text.hasPrefix("File") {
            cell.showBubble = false
            cell.backgroundColor = .lightGray
        }
        else if text.hasPrefix("Comment") {
            cell.showBubble = true
            cell.backgroundColor = .white
            
            var afterBubbleCell = false
            var beforeBubbleCell = false
            
            if indexPath.row > 0 {
                afterBubbleCell = itemsToUse[indexPath.row - 1].hasPrefix("Comment")
            }
            
            if indexPath.row < items.count - 1 {
                beforeBubbleCell = itemsToUse[indexPath.row + 1].hasPrefix("Comment")
            }
            
            let topOffset: CGFloat = afterBubbleCell ? 5 : 17
            let bottomOffset: CGFloat = beforeBubbleCell ? 7 : 19

//            if indexPath == sourceIndexPath {
//                cell.topPadding = 12
//                cell.bottomPadding = 12
//            }
//            else {
                cell.topPadding = topOffset
                cell.bottomPadding = bottomOffset
//            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 60
        
        let itemsToUse: [String]! = items
        
        let text = itemsToUse[indexPath.row]
        
        if text.hasPrefix("File") {
            height = 72
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
        case let .reordering(context) where context.direction != .stationary && context.destinationRow == indexPath:
            // determine the new spacer row height
            postReorderAffectedCellHeights = 0
            
            if context.direction == .down {
                // cell before the previous spacer
                if context.destinationRow.row - 2 >= 0 {
                    if let cellHeight = tableView.delegate?.tableView!(tableView, heightForRowAt: IndexPath(row: context.destinationRow.row - 2, section: 0)) {
                        postReorderAffectedCellHeights += cellHeight
                    }
                }

                // cell after the previous spacer
                if context.destinationRow.row - 1 >= 0 {
                    if let cellHeight = tableView.delegate?.tableView!(tableView, heightForRowAt: IndexPath(row: context.destinationRow.row - 1, section: 0)) {
                        postReorderAffectedCellHeights += cellHeight
                    }
                }
                
                // cell after the new spacer
                if context.destinationRow.row + 1 < items.count - 1 {
                    if let cellHeight = tableView.delegate?.tableView!(tableView, heightForRowAt: IndexPath(row: context.destinationRow.row + 1, section: 0)) {
                        postReorderAffectedCellHeights += cellHeight
                    }
                }
            }
            else {
                // cell after the current spacer
                if context.destinationRow.row + 2 <= items.count - 1 {
                    if let cellHeight = tableView.delegate?.tableView!(tableView, heightForRowAt: IndexPath(row: context.destinationRow.row + 2, section: 0)) {
                        postReorderAffectedCellHeights += cellHeight
                    }
                }
                
                // cell before the current spacer
                if context.destinationRow.row + 1 <= items.count - 1 {
                    if let cellHeight = tableView.delegate?.tableView!(tableView, heightForRowAt: IndexPath(row: context.destinationRow.row + 1, section: 0)) {
                        postReorderAffectedCellHeights += cellHeight
                    }
                }
                
                // cell before the new spacer
                if context.destinationRow.row - 1 >= 0 {
                    if let cellHeight = tableView.delegate?.tableView!(tableView, heightForRowAt: IndexPath(row: context.destinationRow.row - 1, section: 0)) {
                        postReorderAffectedCellHeights += cellHeight
                    }
                }
            }

            
            if useCachedSpacerHeight {
                height = cachedSpacerHeight
            }
            else {
                height = cachedSpacerHeight - (postReorderAffectedCellHeights - preReorderAffectedCellHeights)
                cachedSpacerHeight = height
                
                useCachedSpacerHeight = true
            }
            
            break
    
        // ensure the height of a single line comment is the height of the base bubble (36) + 12 top + 12 bottom padding = 60
        case let .preparing(sourceRow) where indexPath.row == sourceRow.row && itemsToUse[sourceRow.row].hasPrefix("Comment"):
            height = 60
            break
            
        default:
            break
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case let .reordering(context) = tableView.reorder.reorderState, context.destinationRow == indexPath {
            if context.direction == .stationary {
                // height of the initial spacer before any reordering has occurred
                cachedSpacerHeight = cell.frame.size.height
            }
            
            cell.textLabel?.text = "                           \(cell.frame.size.height)"
        }
    }
}

var preReorderAffectedCellHeights: CGFloat = 0
var postReorderAffectedCellHeights: CGFloat = 0
var cachedSpacerHeight: CGFloat = 0
var useCachedSpacerHeight = false

extension BasicReorderHandleViewController: TableViewReorderDelegate {
//    func tableViewWillBeginReordering(_ tableView: UITableView) {
//        reorderItems = items
//    }
    
    func prepareCellForSnapshot(cell: UITableViewCell) {
        guard let cell = cell as? CustomTableViewCell else { return }
        
        if cell.showBubble {
            cell.topPadding = 12
            cell.bottomPadding = 12
        }
        
        cell.backgroundColor = .white
    }
    
    func tableViewDidBeginReordering(_ tableView: UITableView) {
    }
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // calculate the cell heights of the current cells as they exist before doing any reordering has occurred
        guard case let .reordering(context) = tableView.reorder.reorderState, context.direction != .stationary else { return }

        useCachedSpacerHeight = false
        preReorderAffectedCellHeights = 0

        if context.direction == .down {
            // cell before the current spacer
            if context.destinationRow.row - 2 >= 0 {
                if let cell = tableView.cellForRow(at: IndexPath(row: context.destinationRow.row - 2, section: 0)) {
                    preReorderAffectedCellHeights += cell.frame.height
                }
            }
            
            // cell after the current spacer
            if let cell = tableView.cellForRow(at: IndexPath(row: context.destinationRow.row, section: 0)) {
                preReorderAffectedCellHeights += cell.frame.height
            }
            
            // cell after the cell we're moving to
            if context.destinationRow.row + 1 <= items.count - 1 {
                if let cell = tableView.cellForRow(at: IndexPath(row: context.destinationRow.row + 1, section: 0)) {
                    preReorderAffectedCellHeights += cell.frame.height
                }
            }
        }
        else {
            // cell before where we're moving to
            if context.destinationRow.row - 1 >= 0 {
                if let cell = tableView.cellForRow(at: IndexPath(row: context.destinationRow.row - 1, section: 0)) {
                    preReorderAffectedCellHeights += cell.frame.height
                }
            }
            
            // cell before the current spacer
            if let cell = tableView.cellForRow(at: IndexPath(row: context.destinationRow.row, section: 0)) {
                preReorderAffectedCellHeights += cell.frame.height
            }

            // cell after the current spacer
            if context.destinationRow.row + 2 <= items.count - 1 {
                if let cell = tableView.cellForRow(at: IndexPath(row: context.destinationRow.row + 2, section: 0)) {
                    preReorderAffectedCellHeights += cell.frame.height
                }
            }
        }

        
        print("reordering source: \(sourceIndexPath), item \(items[sourceIndexPath.row]) | destination: \(context.destinationRow), item \(items[context.destinationRow.row])")

        let item = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
        
        var previousIndexPath: IndexPath
        var nextIndexPath: IndexPath
        
        // the previous and next cells will change depending on if we're reordering up or down
        if context.direction == .down {
            previousIndexPath = destinationIndexPath
            nextIndexPath = sourceIndexPath
        }
        else {
            previousIndexPath = sourceIndexPath
            nextIndexPath = destinationIndexPath
        }

        // update margins on displaced cell
        updatePaddingOnCellAt(indexPath: destinationIndexPath,
                              previousIndexPath: IndexPath(row: sourceIndexPath.row - 1, section: 0),
                              nextIndexPath: IndexPath(row: sourceIndexPath.row + 1, section: 0))
        
        // update margins on cell previous to moved cell
        updatePaddingOnCellAt(indexPath: IndexPath(row: nextIndexPath.row - 1, section: 0),
                              previousIndexPath: IndexPath(row: nextIndexPath.row - 2, section: 0),
                              nextIndexPath: nextIndexPath)
        
        // update margins on cell after displaced cell
        updatePaddingOnCellAt(indexPath: IndexPath(row: previousIndexPath.row + 1, section: 0),
                              previousIndexPath: previousIndexPath,
                              nextIndexPath: IndexPath(row: previousIndexPath.row + 2, section: 0))
    }
    
    func tableView(_ tableView: UITableView, snapshotOffsetYFor snapshotIndexPath: IndexPath) -> CGFloat {
        let text = items[snapshotIndexPath.row]
        
        if text.hasPrefix("Comment") {
            var afterBubbleCell = false
            let snapshotPadding: CGFloat = 12
            
            if snapshotIndexPath.row > 0 {
                afterBubbleCell = items[snapshotIndexPath.row - 1].hasPrefix("Comment")
            }
            
            let topOffset: CGFloat = afterBubbleCell ? 5 : 17

            return topOffset - snapshotPadding
        }
        
        return 0
    }
}

fileprivate extension BasicReorderHandleViewController {
    func updatePaddingOnCellAt(indexPath: IndexPath, previousIndexPath: IndexPath, nextIndexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell, cell.showBubble else { return }

        var afterBubbleCell = false
        var beforeBubbleCell = false
        
        if previousIndexPath.row >= 0 {
            afterBubbleCell = items[previousIndexPath.row].hasPrefix("Comment")
        }
        
        if nextIndexPath.row <= items.count - 1 {
            beforeBubbleCell = items[nextIndexPath.row].hasPrefix("Comment")
        }
    
        let topOffset: CGFloat = afterBubbleCell ? 5 : 17
        let bottomOffset: CGFloat = beforeBubbleCell ? 7 : 19
        
        cell.topPadding = topOffset
        cell.bottomPadding = bottomOffset
    }
}
