//
//  AutoLayoutTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/11237622/using-autolayout-with-expanding-nstextviews
//----------------------------------------------------------------------------------------------------------------------

protocol AutoLayoutTableViewDelegate : AnyObject {

  func rowCount () -> Int

  func tableViewSelectionDidChange (selectedRows inSelectedRows : IndexSet)

  func indexesOfSelectedObjects () -> IndexSet

  func addEntry ()

  func removeSelectedEntries ()

  func sortDescriptorsDidChangeTo (_ inSortDescriptors : [NSSortDescriptor])
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
                            sortDescriptor inSortDescriptor : NSSortDescriptor?,
                            title inTitle : String,
                            headerAlignment inHeaderAlignment : TextAlignment,
                            contentAlignment inContentAlignment : TextAlignment) -> Self {
    let column = InternalTextTableColumn (
      withIdentifierNamed: String (self.mTableView.tableColumns.count),
      sortDescriptor: inSortDescriptor,
      contentAlignment: inContentAlignment.cocoaAlignment,
      valueSetterDelegate: inSetterDelegate,
      valueGetterDelegate: inGetterDelegate
    )
    column.title = inTitle
    column.headerCell.alignment = inHeaderAlignment.cocoaAlignment
    column.minWidth = 60.0
    column.maxWidth = 400.0
    column.width = 60.0
  //--- Add Column
    self.mTableView.addTableColumn (column)
  //--- Update table view sort descriptors
    if let s = inSortDescriptor {
      self.mTableView.sortDescriptors.append (s)
    }
  //---
    return self
  }

  //····················································································································

  final func addIntObserverColumn (title inTitle : String,
                                   sortDescriptor inSortDescriptor : NSSortDescriptor?,
                                   headerAlignment inHeaderAlignment : NSTextAlignment,
                                   contentAlignment inContentAlignment : NSTextAlignment,
                                   valueDelegate inCallBack : Optional < (_ inRow : Int) -> Int >) -> Self {
    let column = InternalIntObserverTableColumn (
      withIdentifierNamed: String (self.mTableView.tableColumns.count),
      sortDescriptor: inSortDescriptor,
      contentAlignment: inContentAlignment,
      valueDelegate: inCallBack
    )
    column.title = inTitle
    column.headerCell.alignment = inHeaderAlignment
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
    return self
  }

  //····················································································································

  func reloadData () {
    Swift.print ("AutoLayoutTableView reloads data")
  //--- Current selected row
    let currentSelectedRow = self.mTableView.selectedRow // < 0 if no selected row
  //--- Sort Objects
//    for sortDescriptor in self.mTableView.sortDescriptors.reversed () {
//      for column in self.mTableView.tableColumns {
//        if sortDescriptor === column.sortDescriptorPrototype, let c = column as? InternalTableColumn {
//          c.mSortCallBack? (sortDescriptor.ascending)
//        }
//      }
//    }
  //--- Reload; reloading change selection, so we temporary disable transmitting selection change to delegate
    self.mTransmitSelectionChangeToDelegate = false
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
    textField.controlSize = .small
    textField.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: textField.controlSize))

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
    self.mDelegate?.sortDescriptorsDidChangeTo (self.mTableView.sortDescriptors)
//    self.reloadData ()
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
//  let mSortCallBack : Optional < (_ inAscending : Bool) -> Void >

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sortDescriptor inSortDescriptor : NSSortDescriptor?,
        contentAlignment inContentAlignment : NSTextAlignment) {
    self.mContentAlignment = inContentAlignment
    super.init (identifier: NSUserInterfaceItemIdentifier (rawValue: inName))
    noteObjectAllocation (self)

    self.sortDescriptorPrototype = inSortDescriptor
//    if inSortCallBack != nil {
//      self.sortDescriptorPrototype = NSSortDescriptor (key: inName, ascending: true)
//    }
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
        sortDescriptor inSortDescriptor : NSSortDescriptor?,
        contentAlignment inContentAlignment : NSTextAlignment,
        valueSetterDelegate inSetterGelegate : Optional < (_ inRow : Int, _ inNewValue : String) -> Void >,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> String?) {
    self.mValueGetterDelegate = inGetterDelegate
    self.mValueSetterDelegate = inSetterGelegate
    super.init (withIdentifierNamed: inName, sortDescriptor: inSortDescriptor, contentAlignment: inContentAlignment)
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
// InternalIntObserverTableColumn
//----------------------------------------------------------------------------------------------------------------------

fileprivate class InternalIntObserverTableColumn : InternalTableColumn {

  //····················································································································

  private let mValueDelegate : Optional < (_ inRow : Int) -> Int >
  private let mNumberFormatter = NumberFormatter ()

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sortDescriptor inSortDescriptor : NSSortDescriptor?,
        contentAlignment inContentAlignment : NSTextAlignment,
        valueDelegate inCallBack : Optional < (_ inRow : Int) -> Int >) {
    self.mValueDelegate = inCallBack
    super.init (withIdentifierNamed: inName, sortDescriptor: inSortDescriptor, contentAlignment: inContentAlignment)
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
    inTextField.alignment = self.mContentAlignment
    inTextField.integerValue = self.mValueDelegate? (inRow) ?? -1
  //--- Number formatter
    inTextField.formatter = self.mNumberFormatter
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
