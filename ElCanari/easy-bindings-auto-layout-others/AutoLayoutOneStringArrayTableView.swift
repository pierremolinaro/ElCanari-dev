//
//  AutoLayoutOneStringArrayTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//   See https://gist.github.com/wozuo/53a475e67dd11c60cfb1e4f62ea91d32
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

fileprivate let COLUMN_IDENTIFIER = NSUserInterfaceItemIdentifier (rawValue: "MyColumn")

//--------------------------------------------------------------------------------------------------
// NOTE: AutoLayoutOneStringArrayTableView is view based
//--------------------------------------------------------------------------------------------------

@MainActor final class AutoLayoutOneStringArrayTableView : NSScrollView, NSTableViewDataSource, NSTableViewDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mTableView = NSTableView (frame: .zero)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
//    self.translatesAutoresizingMaskIntoConstraints = false
//    self.mTableView.translatesAutoresizingMaskIntoConstraints = false // DO NOT UNCOMMENT

  //--- Configure table view
    self.mTableView.dataSource = self // NSTableViewDataSource protocol
    self.mTableView.delegate = self // NSTableViewDelegate protocol
    self.mTableView.gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
    self.mTableView.usesAlternatingRowBackgroundColors = true
    self.mTableView.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
 //   self.mTableView.headerView = nil // For hiding table view header
    let column = NSTableColumn (identifier: COLUMN_IDENTIFIER)
    column.title = "Forbidden Pad Numbers"
    column.headerCell.alignment = .center
    self.mTableView.addTableColumn (column)

//--- Configure Scroll view
    self.borderType = .bezelBorder // .noBorder
    self.hasHorizontalScroller = false
    self.hasVerticalScroller = true
    self.documentView = self.mTableView
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    return NSSize (width: NSView.noIntrinsicMetric, height: 100.0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   NSTableViewDataSource protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mDataSource.count
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableView (_ tableView : NSTableView, sortDescriptorsDidChange oldDescriptors : [NSSortDescriptor]) {
    self.reloadDataSource (self.mDataSource)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   NSTableViewDelegate protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn : NSTableColumn?,
                  row inRowIndex : Int) -> NSView? {
    let result = NSTableCellView ()
    result.translatesAutoresizingMaskIntoConstraints = false
    let textField = NSTextField (frame: .zero)
    textField.translatesAutoresizingMaskIntoConstraints = false

    //Swift.print (self.mDataSource [inRowIndex])
    textField.stringValue = self.mDataSource [inRowIndex]
    textField.isBezeled = false
    textField.isBordered = false
    textField.drawsBackground = false
    textField.isEditable = false
    textField.alignment = .center
    textField.controlSize = .small
    textField.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: textField.controlSize))
    result.addSubview (textField)
    result.textField = textField
    var constraints = [NSLayoutConstraint] ()
    constraints.add (widthOf: textField, equalToWidthOf: result)
    constraints.add (heightOf: textField, equalToHeightOf: result)
    result.addConstraints (constraints)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  DATA SOURCE
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mDataSource = StringArray ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func reloadDataSource (_ inDataSource : [String]) {
  //--- Note selected rows
    var selectedRowContents = Set <String> ()
    let currentSelectedRowIndexes = self.mTableView.selectedRowIndexes
    for idx in currentSelectedRowIndexes {
      if idx < self.mDataSource.count {
        selectedRowContents.insert (self.mDataSource [idx])
      }
    }
  //--- Sort
    self.mDataSource = inDataSource
    for s in self.mTableView.sortDescriptors.reversed () {
      if let key = s.key, key == "value" {
        self.mDataSource.sort () { String.numericCompare ($0, s.ascending, $1) }
      }else{
        NSLog ("Key '\(String (describing: s.key))' unknown in \(#file):\(#line)")
      }
    }
    self.mTableView.reloadData ()
  //--- Restore selection
    var newSelectedRowIndexes = IndexSet ()
    var idx = 0
    while idx < self.mDataSource.count {
      if selectedRowContents.contains (self.mDataSource [idx]) {
        newSelectedRowIndexes.insert (idx)
      }
      idx += 1
    }
    if (newSelectedRowIndexes.count == 0) && (self.mDataSource.count > 0) {
      if let firstIndex : Int = currentSelectedRowIndexes.first {
        if firstIndex < self.mDataSource.count {
          newSelectedRowIndexes.insert (firstIndex)
        }else{
          newSelectedRowIndexes.insert (self.mDataSource.count - 1)
        }
      }else{
        newSelectedRowIndexes.insert (0)
      }
    }
    self.mTableView.selectRowIndexes (newSelectedRowIndexes, byExtendingSelection: false)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func update (from inModel : EBObservableProperty <StringArray>) {
    switch inModel.selection {
    case .empty, .multiple :
      self.reloadDataSource ([])
    case .single (let unconnectedPadArray) :
      self.reloadDataSource (unconnectedPadArray)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $array binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_array (_ model : EBObservableProperty <StringArray>) -> Self {
    self.mController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_array () {
//    self.mController?.unregister ()
//    self.mController = nil
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SELECTED TITLE
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var selectedItemTitle : String? {
    if self.mTableView.selectedRow >= 0 {
      return self.mDataSource [self.mTableView.selectedRow]
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
