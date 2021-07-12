//
//  AutoLayoutCanariIssueTableView.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 26/02/2021.
//
// See https://gist.github.com/wozuo/53a475e67dd11c60cfb1e4f62ea91d32
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let LEFT_COLUMN_IDENTIFIER  = NSUserInterfaceItemIdentifier (rawValue: "left")
fileprivate let RIGHT_COLUMN_IDENTIFIER = NSUserInterfaceItemIdentifier (rawValue: "right")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariIssueTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariIssueTableView : AutoLayoutVerticalStackView, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································

  private var mScrollView = EmbeddedAutoLayoutScrollView ()
  private var mTableView = EmbeddedAutoLayoutTableView ()
  private var mHideIssueButton : AutoLayoutButton

  //····················································································································
  //   init
  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override init () {
    self.mHideIssueButton = AutoLayoutButton (title: "Hide Issue", small: true).expandableWidth ()
    super.init ()
    self.translatesAutoresizingMaskIntoConstraints = false
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .vertical)

    self.mHideIssueButton.target = self
    self.mHideIssueButton.action = #selector (Self.hideIssueAction (_:))
    self.appendView (self.mHideIssueButton)

    self.mTableView.dataSource = self
    self.mTableView.delegate = self
    self.mTableView.headerView = nil
    self.mTableView.gridStyleMask = .dashedHorizontalGridLineMask
    self.mTableView.controlSize = .small
    self.mTableView.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.mTableView.controlSize))

    let leftColumn = NSTableColumn (identifier: LEFT_COLUMN_IDENTIFIER)
    leftColumn.minWidth = 20.0
    leftColumn.maxWidth = 20.0
    leftColumn.isEditable = false
    leftColumn.resizingMask = [] // Not resizable
    self.mTableView.addTableColumn (leftColumn)

    let rightColumn = NSTableColumn (identifier: RIGHT_COLUMN_IDENTIFIER)
    rightColumn.minWidth = 100.0
    rightColumn.isEditable = false
    rightColumn.resizingMask = .autoresizingMask
    self.mTableView.addTableColumn (rightColumn)

    self.mScrollView.documentView = self.mTableView
    self.mScrollView.hasHorizontalScroller = false
    self.mScrollView.hasVerticalScroller = true
    self.appendView (self.mScrollView)
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    return NSSize (width: 50.0, height: 50.0)
  }

  //····················································································································

  override func ebCleanUp () {
    self.mIssueController?.unregister ()
    self.mIssueController = nil
    self.mTableView.dataSource = nil
    self.mTableView.delegate = nil
    super.ebCleanUp ()
  }

  //····················································································································

  @objc fileprivate func hideIssueAction (_ inSender : Any?) {
    self.mTableView.deselectAll (inSender)
  }

  //····················································································································

  func tableView (_ tableView: NSTableView, rowViewForRow inRow : Int) -> NSTableRowView? {
    let rowView = NSTableRowView ()
    rowView.isEmphasized = false
    return rowView
  }

  //····················································································································

  func tableView (_ tableView : NSTableView, viewFor inTableColumn : NSTableColumn?, row inRow : Int) -> NSView? {
    var result : NSView? = nil
    if let tableColumn = inTableColumn {
      if tableColumn.identifier == LEFT_COLUMN_IDENTIFIER {
        let imageView = NSImageView (frame: NSRect ())
        switch self.mModelArray [inRow].kind {
        case .error :
          imageView.image = NSImage (named: NSImage.statusUnavailableName)
        case .warning :
          imageView.image = NSImage (named: NSImage.statusPartiallyAvailableName)
        }
        let cell = NSTableCellView ()
        cell.addSubview (imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cell.addConstraint (NSLayoutConstraint (item: imageView, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0))
        cell.addConstraint (NSLayoutConstraint (item: imageView, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 0))
        cell.addConstraint (NSLayoutConstraint (item: imageView, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: 0))
        result = cell
      }else if tableColumn.identifier == RIGHT_COLUMN_IDENTIFIER {
        let text = NSTextField ()
        text.alignment = .left
        text.stringValue = self.mModelArray [inRow].message
        text.toolTip = text.stringValue
        let cell = NSTableCellView ()
        cell.addSubview (text)
        text.drawsBackground = false
        text.isBordered = false
        text.translatesAutoresizingMaskIntoConstraints = false
        cell.addConstraint (NSLayoutConstraint (item: text, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0))
        cell.addConstraint (NSLayoutConstraint (item: text, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 0))
        cell.addConstraint (NSLayoutConstraint (item: text, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: 0))
        result = cell
      }
    }
    return result
  }

  //····················································································································
  //    Selected issue display
  //····················································································································

  private weak var mIssueDisplayView : AutoLayoutGraphicView? = nil

  //····················································································································

  func register (issueDisplayView : AutoLayoutGraphicView?) {
    self.mIssueDisplayView = issueDisplayView
    self.updateIssueDisplay ()
  }

  //····················································································································

  private func updateIssueDisplay () {
    if self.mTableView.selectedRow < 0 {
      self.mIssueDisplayView?.setIssue ([], .error)
      self.mHideIssueButton.isEnabled = false
    }else{
      let selectedIssue = self.mModelArray [self.mTableView.selectedRow]
      self.mIssueDisplayView?.setIssue (selectedIssue.pathes, selectedIssue.kind)
      self.mHideIssueButton.isEnabled = true
    }
  }

  //····················································································································
  //    Issues
  //····················································································································

  fileprivate var mModelArray = [CanariIssue] () {
    didSet {
      self.mTableView.reloadData ()
      self.updateIssueDisplay ()
    }
  }

  //····················································································································

  func setIssues (_ inIssues : [CanariIssue]) {
    self.mModelArray = inIssues.sorted (by: CanariIssue.displaySortingCompare)
  }

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  func numberOfRows (in tableView : NSTableView) -> Int {
    return self.mModelArray.count
  }

  //····················································································································
  //    Table view delegate
  //····················································································································

  func tableViewSelectionDidChange (_ notification : Notification) {
    self.updateIssueDisplay ()
  }

  //····················································································································
  //    $issues binding
  //····················································································································

  private var mIssueController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_issues (_ inModel : EBReadOnlyProperty_CanariIssueArray) -> Self {
    self.mIssueController = EBReadOnlyPropertyController (
      observedObjects: [inModel],
      callBack: { self.update (from: inModel) }
    )
    return self
  }

  //····················································································································

  private func update (from inModel : EBReadOnlyProperty_CanariIssueArray) {
    switch inModel.selection {
    case .empty :
      self.mModelArray = []
    case .single (let v) :
      self.mModelArray = v
    case .multiple :
      self.mModelArray = []
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final fileprivate class EmbeddedAutoLayoutScrollView : NSScrollView, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final fileprivate class EmbeddedAutoLayoutTableView : NSTableView, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
