//
//  AutoLayoutTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

protocol AutoLayoutTableViewDelegate : AnyObject {

  func rowCount () -> Int
  func tableViewSelectionDidChange (selectedRows inSelectedRows : IndexSet)
  func indexesOfSelectedObjects () -> IndexSet
  func addEntry ()
  func removeSelectedEntries ()

  func beginSorting ()
  func endSorting ()
}

//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutTableView : AutoLayoutVerticalStackView, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································

  private let mScrollView = NSScrollView (frame: NSRect ())
  private let mTableView = NSTableView (frame: NSRect ())
  private var mAddButton : AutoLayoutButton? = nil
  private var mRemoveButton : AutoLayoutButton? = nil
  private weak var mDelegate : AutoLayoutTableViewDelegate? = nil // SHOULD BE WEAK
  private var mTransmitSelectionChangeToDelegate = true

  //····················································································································

  init (small inSmall : Bool, addControlButtons inAddControlButtons : Bool) {
    super.init ()
  //--- Configure table view
    self.mTableView.controlSize = inSmall ? .small : .regular
    self.mTableView.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.mTableView.controlSize))
    self.mTableView.focusRingType = .none
    self.mTableView.delegate = self
    self.mTableView.dataSource = self
    self.mTableView.gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
    self.mTableView.usesAlternatingRowBackgroundColors = true
    self.mTableView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
  //--- Configure scroll view
    self.mScrollView.hasVerticalScroller = true
    self.mScrollView.borderType = .bezelBorder
    self.mScrollView.documentView = self.mTableView
  //---
    self.appendView (self.mScrollView)
    if inAddControlButtons {
      let hStack = AutoLayoutHorizontalStackView ()
      let addButton = AutoLayoutButton (title: "+", small: inSmall)
        .bind_run (target: self, selector: #selector (Self.addEntryAction (_:)))
      self.mAddButton = addButton
      hStack.appendView (addButton)
      let removeButton = AutoLayoutButton (title: "-", small: inSmall)
        .bind_run (target: self, selector: #selector (Self.removeSelectedEntriesAction (_:)))
      self.mRemoveButton = removeButton
      hStack.appendView (removeButton)
      hStack.appendFlexibleSpace ()
      self.appendView (hStack)
    }
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func makeWidthExpandable () -> Self {
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    return self
  }

  //····················································································································

  final func configure (allowsEmptySelection inAllowsEmptySelection : Bool,
                        allowsMultipleSelection inAllowsMultipleSelection : Bool,
                        delegate inDelegate : AutoLayoutTableViewDelegate) {
    // Swift.print ("inAllowsEmptySelection \(inAllowsEmptySelection) inAllowsMultipleSelection \(inAllowsMultipleSelection)")
    self.mTableView.allowsEmptySelection = inAllowsEmptySelection
    self.mTableView.allowsMultipleSelection = inAllowsMultipleSelection
    self.mDelegate = inDelegate
  }

  //····················································································································

  @objc func addEntryAction (_ inUnusedSender : Any?) {
    self.mDelegate?.addEntry ()
  }

  //····················································································································

  @objc func removeSelectedEntriesAction (_ inUnusedSender : Any?) {
    self.mDelegate?.removeSelectedEntries ()
  }

  //····················································································································

  final func addTextColumn (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> String?,
                            valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : String) -> Void >,
                            sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                            title inTitle : String,
                            headerAlignment inHeaderAlignment : TextAlignment,
                            contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalTextTableColumn (
      withIdentifierNamed: String (self.mTableView.tableColumns.count),
      sortDelegate: inSortDelegate,
      contentAlignment: inContentAlignment.cocoaAlignment,
      valueSetterDelegate: inSetterDelegate,
      valueGetterDelegate: inGetterDelegate
    )
    column.title = inTitle
    column.headerCell.controlSize = self.mTableView.controlSize
    column.headerCell.font = self.mTableView.font
    column.headerCell.alignment = inHeaderAlignment.cocoaAlignment
    column.minWidth = 60.0
    column.maxWidth = 400.0
    column.width = 60.0
  //--- Add Column
    self.mTableView.addTableColumn (column)
  //--- Update table view sort descriptors
    if let s = column.sortDescriptorPrototype {
      self.mTableView.sortDescriptors.append (s)
    }
  //---
//    return self
  }

  //····················································································································

  final func addIntColumn (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> Int?,
                           valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Int) -> Void >,
                           sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                           title inTitle : String,
                           headerAlignment inHeaderAlignment : TextAlignment,
                           contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalIntTableColumn (
      withIdentifierNamed: String (self.mTableView.tableColumns.count),
      sortDelegate: inSortDelegate,
      contentAlignment: inContentAlignment.cocoaAlignment,
      valueSetterDelegate: inSetterDelegate,
      valueGetterDelegate: inGetterDelegate
    )
    column.title = inTitle
    column.headerCell.controlSize = self.mTableView.controlSize
    column.headerCell.font = self.mTableView.font
    column.headerCell.alignment = inHeaderAlignment.cocoaAlignment
    column.minWidth = 80.0
    column.maxWidth = 400.0
    column.width = 80.0
  //--- Add Column
    self.mTableView.addTableColumn (column)
  //--- Update table view sort descriptors
    if let s = column.sortDescriptorPrototype {
      self.mTableView.sortDescriptors.append (s)
    }
  //---
//    return self
  }

  //····················································································································

  func sortAndReloadData () {
    // Swift.print ("AutoLayoutTableView reloads data")
  //--- Current selected row
    let currentSelectedRow = self.mTableView.selectedRow // < 0 if no selected row
  //--- Reload; reloading change selection, so we temporary disable transmitting selection change to delegate
    self.mTransmitSelectionChangeToDelegate = false
    self.mDelegate?.beginSorting ()
    for descriptor in self.mTableView.sortDescriptors.reversed () {
      for tableColumn in self.mTableView.tableColumns {
        if let column = tableColumn as? InternalTableColumn, column.identifier.rawValue == descriptor.key {
          column.mSortDelegate? (descriptor.ascending)
        }
      }
    }
    self.mDelegate?.endSorting ()
    self.mTableView.reloadData ()
    self.mTransmitSelectionChangeToDelegate = true
  //--- Restore Selection
    if let selectedObjectIndexes = self.mDelegate?.indexesOfSelectedObjects () {
      self.mTableView.selectRowIndexes (selectedObjectIndexes, byExtendingSelection: false)
    }
  //--- Ensure selection non empty ?
    if self.mTableView.selectedRow < 0, !self.mTableView.allowsEmptySelection, let rowCount = self.mDelegate?.rowCount (), rowCount > 0 {
      if currentSelectedRow >= 0 {
        if currentSelectedRow < rowCount {
          self.mTableView.selectRowIndexes (IndexSet (integer: currentSelectedRow), byExtendingSelection: false)
        }else{
          self.mTableView.selectRowIndexes (IndexSet (integer: rowCount - 1), byExtendingSelection: false)
        }
      }else{
        self.mTableView.selectRowIndexes (IndexSet (integer: 0), byExtendingSelection: false)
      }
    }
  }

  //····················································································································
  //   NSTableViewDataSource protocol
  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    let n = self.mDelegate?.rowCount () ?? 0
    return n
  }

  //····················································································································
  //   NSTableViewDelegate protocol
  //····················································································································

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn : NSTableColumn?,
                  row inRowIndex : Int) -> NSView? {
    let result = NSTableCellView ()
    result.translatesAutoresizingMaskIntoConstraints = false
    let textField = NSTextField (frame: NSRect ())
    textField.translatesAutoresizingMaskIntoConstraints = false

    textField.tag = inRowIndex
    textField.isBezeled = false
    textField.isBordered = false
    textField.drawsBackground = false
    textField.isEnabled = true
    textField.controlSize = self.mTableView.controlSize
    textField.font = self.mTableView.font // NSFont.systemFont (ofSize: NSFont.systemFontSize (for: textField.controlSize))

    if let tableColumn = inTableColumn as? InternalTableColumn {
      tableColumn.setValueToTextField (textField, inRowIndex)
    }else{
      textField.stringValue = "?col?"
    }

    result.addSubview (textField)
    result.textField = textField
    let c1 = NSLayoutConstraint (item: textField, attribute: .width, relatedBy: .equal, toItem: result, attribute: .width, multiplier: 1.0, constant: 0.0)
    let c2 = NSLayoutConstraint (item: textField, attribute: .height, relatedBy: .equal, toItem: result, attribute: .height, multiplier: 1.0, constant: 0.0)
    result.addConstraints ([c1, c2])
    return result
  }

  //····················································································································
  //    tableView:sortDescriptorsDidChange: NSTableViewDataSource delegate
  //····················································································································

  func tableView (_ tableView : NSTableView,
                  sortDescriptorsDidChange oldDescriptors : [NSSortDescriptor]) {
    self.sortAndReloadData ()
  }

  //····················································································································
  //    T A B L E V I E W    D E L E G A T E : tableViewSelectionDidChange:
  //····················································································································

  func tableViewSelectionDidChange (_ notification : Notification) {
    if mTransmitSelectionChangeToDelegate {
      self.mDelegate?.tableViewSelectionDidChange (selectedRows: self.mTableView.selectedRowIndexes)
    }
    self.mRemoveButton?.enable (fromEnableBinding: !self.mTableView.selectedRowIndexes.isEmpty)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
// InternalTableColumn
//----------------------------------------------------------------------------------------------------------------------

fileprivate class InternalTableColumn : NSTableColumn, EBUserClassNameProtocol {

  //····················································································································

  let mContentAlignment : NSTextAlignment
  let mSortDelegate : Optional < (_ inAscending : Bool) -> Void>

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment) {
    self.mContentAlignment = inContentAlignment
    self.mSortDelegate = inSortDelegate
    super.init (identifier: NSUserInterfaceItemIdentifier (rawValue: inName))
    noteObjectAllocation (self)

    if inSortDelegate != nil {
 //     self.sortDescriptorPrototype = InternalSortDescriptor (columnIdentifierName: inName, sorterDelegate: sortDelegate)
      self.sortDescriptorPrototype = NSSortDescriptor (key: inName, ascending: true)
    }else{
      self.sortDescriptorPrototype = nil
    }
  }

  //····················································································································

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func setValueToTextField (_ inTextField : NSTextField, _ inRow : Int) { // Abstract value
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
// InternalTextTableColumn
//----------------------------------------------------------------------------------------------------------------------

fileprivate class InternalTextTableColumn : InternalTableColumn {

  //····················································································································

  private let mValueGetterDelegate : (_ inRow : Int) -> String?
  private let mValueSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : String) -> Void >

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment,
        valueSetterDelegate inSetterGelegate : Optional < (_ inRow : Int, _ inNewValue : String) -> Void >,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> String?) {
    self.mValueGetterDelegate = inGetterDelegate
    self.mValueSetterDelegate = inSetterGelegate
    super.init (withIdentifierNamed: inName, sortDelegate: inSortDelegate, contentAlignment: inContentAlignment)
  }

  //····················································································································

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func setValueToTextField (_ inTextField : NSTextField, _ inRow : Int) { // Abstract value

    inTextField.alignment = self.mContentAlignment
    inTextField.stringValue = self.mValueGetterDelegate (inRow) ?? ""
    inTextField.isEditable = self.mValueSetterDelegate != nil
//    inTextField.delegate = self
    inTextField.target = self
    inTextField.action = #selector (Self.ebAction(_:))
  }

  //····················································································································
  // IMPLEMENTATION OF NSTextFieldDelegate
  //····················································································································

//  @objc func controlTextDidChange (_ inNotification : Notification) {
//    NSSound.beep ()
//  }

  //····················································································································

  @objc func ebAction (_ inSender : Any?) {
    if let textField = inSender as? NSTextField {
      let rowIndex = textField.tag
      let newValue = textField.stringValue
      self.mValueSetterDelegate? (rowIndex, newValue)
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
// InternalIntTableColumn
//----------------------------------------------------------------------------------------------------------------------

fileprivate class InternalIntTableColumn : InternalTableColumn {

  //····················································································································

  private let mValueGetterDelegate : (_ inRow : Int) -> Int?
  private let mValueSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : Int) -> Void >
  private let mNumberFormatter = NumberFormatter ()

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment,
        valueSetterDelegate inSetterGelegate : Optional < (_ inRow : Int, _ inNewValue : Int) -> Void >,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> Int?) {
    self.mValueGetterDelegate = inGetterDelegate
    self.mValueSetterDelegate = inSetterGelegate
    super.init (withIdentifierNamed: inName, sortDelegate: inSortDelegate, contentAlignment: inContentAlignment)
  //--- Configure number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 0
    self.mNumberFormatter.maximumFractionDigits = 0
    self.mNumberFormatter.isLenient = true
  }

  //····················································································································

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func setValueToTextField (_ inTextField : NSTextField, _ inRow : Int) { // Abstract value
    inTextField.formatter = self.mNumberFormatter
    inTextField.alignment = self.mContentAlignment
    inTextField.integerValue = self.mValueGetterDelegate (inRow) ?? -1
    inTextField.isEditable = self.mValueSetterDelegate != nil
//    inTextField.delegate = self
    inTextField.target = self
    inTextField.action = #selector (Self.ebAction(_:))
  }

  //····················································································································
  // IMPLEMENTATION OF NSTextFieldDelegate
  //····················································································································

//  @objc func controlTextDidChange (_ inNotification : Notification) {
//    NSSound.beep ()
//  }

  //····················································································································

  @objc func ebAction (_ inSender : Any?) {
    if let textField = inSender as? NSTextField,
       let formatter = textField.formatter as? NumberFormatter,
       let outletValueNumber = formatter.number (from: textField.stringValue) {
      let newValue = Int (outletValueNumber.doubleValue.rounded ())
      let rowIndex = textField.tag
      self.mValueSetterDelegate? (rowIndex, newValue)
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
// InternalSortDescriptor
//----------------------------------------------------------------------------------------------------------------------

//fileprivate class InternalSortDescriptor : NSSortDescriptor {
//
//  //····················································································································
//
//  let mSorterDelegate : () -> Void
//
//  //····················································································································
//
//  init (columnIdentifierName inName : String, sorterDelegate inSorterDelegate : @escaping () -> Void) {
//    self.mSorterDelegate = inSorterDelegate
//    super.init (key: inName, ascending: true, selector: nil)
//  }
//
//  //····················································································································
//
//  required init (coder inCoder : NSCoder) {
//    fatalError ("init(coder:) has not been implemented")
//  }
//
//  //····················································································································
//
//}

//----------------------------------------------------------------------------------------------------------------------
