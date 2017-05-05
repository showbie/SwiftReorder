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

/**
 The style of the reorder spacer cell. Determines whether the cell separator line is visible.
 
 - Automatic: The style is determined based on the table view's style (plain or grouped).
 - Hidden: The spacer cell is hidden, and the separator line is not visible.
 - Transparent: The spacer cell is given a transparent background color, and the separator line is visible.
 */
public enum ReorderSpacerCellStyle {
    case automatic
    case hidden
    case transparent
}

// MARK: - TableViewReorderDelegate

/**
 The delegate of a `ReorderController` must adopt the `TableViewReorderDelegate` protocol. This protocol defines methods for handling the reordering of rows.
 */
public protocol TableViewReorderDelegate: class {
    
    /**
     Tells the delegate that the user has moved a row from one location to another. Use this method to update your data source.
     - Parameter tableView: The table view requesting this action.
     - Parameter sourceIndexPath: The index path of the row to be moved.
     - Parameter destinationIndexPath: The index path of the row's new location.
     */
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
    /**
     Asks the reorder delegate whether a given row can be moved.
     - Parameter tableView: The table view requesting this information.
     - Parameter indexPath: The index path of a row.
     */
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool

    /**
     Tells the delegate that the user is aboue to begin reordering a row.
     - Parameter tableView: The table view providing this information.
     */
    func tableViewWillBeginReordering(_ tableView: UITableView)

    /**
     Tells the delegate that the user has begun reordering a row.
     - Parameter tableView: The table view providing this information.
     */
    func tableViewDidBeginReordering(_ tableView: UITableView)

    /**
     Tells the delegate that the user is about to finish reordering.
     - Parameter tableView: The table view providing this information.
     */
    func tableViewWillFinishReordering(_ tableView: UITableView)

    /**
     Tells the delegate that the user has finished reordering.
     - Parameter tableView: The table view providing this information.
     */
    func tableViewDidFinishReordering(_ tableView: UITableView)
    
    func tableView(_ tableView: UITableView, snapshotOffsetYFor snapshotIndexPath: IndexPath) -> CGFloat
    
    func tableView(_ tableView: UITableView, prepareForSnapshot cell: UITableViewCell)
    
    /// Tells the delegate that the snapshot view is about to be displayed, allowing any last minute customizations before it's displayed.
    ///
    /// - Parameter view: The cell snapshot view.
    func tableView(_ tableView: UITableView, willDisplay snapshotView: UIView)
}

public extension TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableViewWillBeginReordering(_ tableView: UITableView) {
    }
    
    func tableViewDidBeginReordering(_ tableView: UITableView) {
    }
    
    func tableViewWillFinishReordering(_ tableView: UITableView) {
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView) {
    }

    func tableView(_ tableView: UITableView, snapshotOffsetYFor snapshotIndexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, prepareForSnapshot cell: UITableViewCell) {
    }
    
    func tableView(_ tableView: UITableView, willDisplay snapshotView: UIView) {
    }
}

// MARK: - ReorderController

/**
 An object that manages drag-and-drop reordering of table view cells.
 */
public class ReorderController: NSObject {
    
    // MARK: - Public interface
    
    /// The delegate of the reorder controller.
    public weak var delegate: TableViewReorderDelegate?
    
    public var longPressDuration: TimeInterval = 0.3 {
        didSet {
            reorderGestureRecognizer.minimumPressDuration = longPressDuration
        }
    }
    
    /// The duration of the cell selection animation.
    public var animationDuration: TimeInterval = 0.2
    
    /// The opacity of the selected cell.
    public var cellOpacity: CGFloat = 1
    
    /// The scale factor for the selected cell.
    public var cellScale: CGFloat = 1
    
    /// The shadow color for the selected cell.
    public var shadowColor = UIColor.black
    
    /// The shadow opacity for the selected cell.
    public var shadowOpacity: CGFloat = 0.3
    
    /// The shadow radius for the selected cell.
    public var shadowRadius: CGFloat = 10
    
    /// The shadow offset for the selected cell.
    public var shadowOffset = CGSize(width: 0, height: 3)
    
    /// The spacer cell style.
    public var spacerCellStyle: ReorderSpacerCellStyle = .automatic
    
    /// True, if the table view will use custom reorder handles to trigger the reorder operation. False, if the default long press gesture should be used.
    public var useReorderHandles = false
    
    /// The snapshot view will be offset by this amount vertically when initially displayed.
    public var snapshotViewOffsetY: CGFloat = 0
    
    /// If true, reordering via long press or reorder handles is enabled. Set to false to disable reordering.
    public var isReorderingEnabled = true {
        didSet {
            reorderGestureRecognizer.isEnabled = isReorderingEnabled
        }
    }
    
    // MARK: - Internal state
    
    public enum ReorderState {
        case ready(snapshotRow: IndexPath?)
        case preparing(sourceRow: IndexPath)
        case reordering(sourceRow: IndexPath, destinationRow: IndexPath, snapshotOffset: CGFloat, direction: ReorderDirection)
    }
    
    public enum ReorderDirection {
        case up
        case down
        case stationary     // reorder has begun but a swipe to reorder hasn't begun yet
    }
    
    internal weak var tableView: UITableView?
    
    public var reorderState: ReorderState = .ready(snapshotRow: nil)
    internal var snapshotView: UIView? = nil
    
    internal var autoScrollDisplayLink: CADisplayLink?
    internal var lastAutoScrollTimeStamp: CFTimeInterval?
    
    internal lazy var reorderGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleReorderGesture))
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = self.longPressDuration
        return gestureRecognizer
    }()
    
    // MARK: - Lifecycle
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        tableView.addGestureRecognizer(reorderGestureRecognizer)
        
        reorderState = .ready(snapshotRow: nil)
    }
    
    // MARK: - Reordering
    
    internal func beginReorder(touchPoint: CGPoint) {
        guard case .ready = reorderState else { return }
        guard let tableView = tableView, let sourceRow = tableView.indexPathForRow(at: touchPoint) else { return }
        
        guard delegate?.tableView(tableView, canReorderRowAt: sourceRow) != false else { return }
        
        reorderState = .preparing(sourceRow: sourceRow)

        delegate?.tableViewWillBeginReordering(tableView)
        
        createSnapshotViewForCell(at: sourceRow)
        animateSnapshotViewIn()
        activateAutoScrollDisplayLink()
        
        tableView.reloadData()
        
        let snapshotOffset = snapshotView.flatMap { $0.center.y - touchPoint.y } ?? 0
        reorderState = .reordering(
            sourceRow: sourceRow,
            destinationRow: sourceRow,
            snapshotOffset: snapshotOffset,
            direction: .stationary
        )

        delegate?.tableViewDidBeginReordering(tableView)
    }
    
    internal func updateReorder(touchPoint: CGPoint) {
        guard case let .reordering(_, _, snapshotOffset, _) = reorderState else { return }
        guard let snapshotView = snapshotView else { return }
        
        snapshotView.center.y = touchPoint.y + snapshotOffset
        updateDestinationRow()
    }
    
    internal func endReorder() {
        guard case let .reordering(_, destinationRow, _, _) = reorderState else { return }
        guard let tableView = tableView else { return }
        
        reorderState = .ready(snapshotRow: destinationRow)
        
        let rect = tableView.rectForRow(at: destinationRow)
        let rectCenter = CGPoint(x: rect.midX, y: rect.midY)
        
        // If no values actually change inside a UIView animation block, the completion handler is called immediately.
        // This is a workaround for that case.
        if snapshotView?.center == rectCenter {
            snapshotView?.center.y += 0.1
        }
        
        delegate?.tableViewWillFinishReordering(tableView)
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.snapshotView?.center = CGPoint(x: rect.midX, y: rect.midY)
        }, completion: { finished in
            if case let .ready(snapshotRow) = self.reorderState {
                if let snapshotRow = snapshotRow {
                    self.reorderState = .ready(snapshotRow: nil)
                    UIView.performWithoutAnimation {
                        tableView.reloadRows(at: [snapshotRow], with: .none)
                    }
                    self.removeSnapshotView()
                }
            }
        })
        animateSnapshotViewOut()
        clearAutoScrollDisplayLink()
        
        delegate?.tableViewDidFinishReordering(tableView)
    }
    
    // MARK: - Spacer cell
    
    /**
     Returns a `UITableViewCell` if the table view should display a spacer cell at the given index path.
     
     Use this method at the beginning of your `tableView(_:cellForRowAt:)`, like so:
     ```
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if let spacer = tableView.reorder.spacerCell(for: indexPath) {
             return spacer
         }
     
         // ...
     }
     ```
     - Parameter indexPath: The index path
     - Returns: An optional `UITableViewCell`.
     */
    public func spacerCell(for indexPath: IndexPath) -> UITableViewCell? {
        if case let .reordering(_, destinationRow, _, _) = reorderState , indexPath == destinationRow {
            return spacerCell()
        } else if case let .ready(snapshotRow) = reorderState , indexPath == snapshotRow {
            return spacerCell()
        }
        return nil
    }
    
    private func spacerCell() -> UITableViewCell? {
        guard let snapshotView = snapshotView else { return nil }
        
        let cell = UITableViewCell()
        let height = snapshotView.bounds.height
        NSLayoutConstraint(item: cell, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: height).isActive = true
        
        let hideCell: Bool
        switch spacerCellStyle {
        case .automatic:
            hideCell = tableView?.style == .grouped
        case .hidden:
            hideCell = true
        case .transparent:
            hideCell = false
        }
        
        if hideCell {
            cell.isHidden = true
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
}
