//
//  AutoLayoutTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutTableView : AutoLayoutVerticalStackView, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································

  private let mScrollView = AutoLayoutScrollView ()
  private let mTableView : InternalAutoLayoutTableView
  private var mAddButton : AutoLayoutButton? = nil
  private var mRemoveButton : AutoLayoutButton? = nil
  private weak var mDelegate : AutoLayoutTableViewDelegate? = nil // SHOULD BE WEAK
  private var mRowCountCallBack : Optional < () -> Int > = nil

  private var mTransmitSelectionChangeToDelegate = true

  //····················································································································

  init (size inSize : EBControlSize, addControlButtons inAddControlButtons : Bool) {
    self.mTableView = InternalAutoLayoutTableView (size: inSize)
    super.init ()

    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.mTableView.setContentHuggingPriority (.defaultLow, for: .horizontal)

  //--- Configure table view
    self.mTableView.controlSize = inSize.cocoaControlSize
    self.mTableView.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.mTableView.controlSize))
    self.mTableView.focusRingType = .none
    self.mTableView.isEnabled = true
    self.mTableView.delegate = self
    self.mTableView.dataSource = self
    self.mTableView.gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
    self.mTableView.usesAlternatingRowBackgroundColors = true
    self.mTableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
    self.mTableView.usesAutomaticRowHeights = true // #available macOS 10.13
    _ = self.setIntercellSpacing (horizontal: 5, vertical: 5)
  //--- Configure scroll view
    self.mScrollView.translatesAutoresizingMaskIntoConstraints = false
    self.mScrollView.hasVerticalScroller = true
    self.mScrollView.borderType = .bezelBorder
    self.mScrollView.documentView = self.mTableView
  //---
    self.appendView (self.mScrollView)
    if inAddControlButtons {
      let hStack = AutoLayoutHorizontalStackView ()
      let addButton = AutoLayoutButton (title: "+", size: inSize)
        .bind_run (target: self, selector: #selector (Self.addEntryAction (_:)))
      self.mAddButton = addButton
      hStack.appendView (addButton)
      let removeButton = AutoLayoutButton (title: "-", size: inSize)
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
  //  Configure table view
  //····················································································································

  final func configure (allowsEmptySelection inAllowsEmptySelection : Bool,
                        allowsMultipleSelection inAllowsMultipleSelection : Bool,
                        rowCountCallBack inRowCountCallBack : @escaping () -> Int,
                        delegate inDelegate : AutoLayoutTableViewDelegate?) {
    // Swift.print ("inAllowsEmptySelection \(inAllowsEmptySelection) inAllowsMultipleSelection \(inAllowsMultipleSelection)")
    self.mTableView.allowsEmptySelection = inAllowsEmptySelection
    self.mTableView.allowsMultipleSelection = inAllowsMultipleSelection
    self.mRowCountCallBack = inRowCountCallBack
    self.mDelegate = inDelegate
  }

  //····················································································································

  func noHeaderView () -> Self {
    self.mTableView.headerView = nil
    self.mTableView.cornerView = nil
    return self
  }

  //····················································································································

  func setIntercellSpacing (horizontal inX : Int, vertical inY : Int) -> Self {
    self.mTableView.intercellSpacing = NSSize (width: inX, height: inY)
    return self
  }

  //····················································································································

  func set (hasHorizontalGrid inFlag : Bool) -> Self {
    if inFlag {
      self.mTableView.gridStyleMask.insert (.solidHorizontalGridLineMask)
    }else{
      self.mTableView.gridStyleMask.remove (.solidHorizontalGridLineMask)
    }
    return self
  }
  
  //····················································································································

  func set (usesAlternatingRowBackgroundColors inFlag : Bool) -> Self {
    self.mTableView.usesAlternatingRowBackgroundColors = inFlag
    return self
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

  var columnCount : Int {
    return self.mTableView.tableColumns.count
  }

  //····················································································································

  var font : NSFont? {
    return self.mTableView.font
  }

  //····················································································································

  var controlSize : NSControl.ControlSize {
    return self.mTableView.controlSize
  }

  //····················································································································

  func appendTableColumn (_ inColumn : AutoLayoutTableColumn) {
  //--- Add Column
    self.mTableView.addTableColumn (inColumn)
  //--- Update table view sort descriptors
    if let s = inColumn.sortDescriptorPrototype {
      self.mTableView.sortDescriptors.append (s)
    }
  }

  //····················································································································

  func scrollRowToVisible (row inRow : Int) {
    self.mTableView.scrollRowToVisible (inRow)
  }

  //····················································································································

  func sortAndReloadData () {
    // Swift.print ("AutoLayoutTableView reloads data")
  //--- Current selected row
    let currentSelectedRow = self.mTableView.selectedRow // < 0 if no selected row
    // Swift.print ("currentSelectedRow \(currentSelectedRow)")
  //--- Reload; reloading change selection, so we temporary disable transmitting selection change to delegate
    self.mTransmitSelectionChangeToDelegate = false
    self.mDelegate?.beginSorting ()
    for descriptor in self.mTableView.sortDescriptors.reversed () {
      for tableColumn in self.mTableView.tableColumns {
        if let column = tableColumn as? AutoLayoutTableColumn, column.identifier.rawValue == descriptor.key {
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
      if selectedObjectIndexes.isEmpty {
        self.mDelegate?.tableViewSelectionDidChange (selectedRows: IndexSet ())
      }
    }else{
      self.mTableView.selectRowIndexes (IndexSet (), byExtendingSelection: false)
    }
  //--- Ensure selection non empty ?
    let ensureNonEmpty = (currentSelectedRow >= 0) || !self.mTableView.allowsEmptySelection
    // Swift.print ("self.mTableView.selectedRow \(self.mTableView.selectedRow), \(self.mTableView.allowsEmptySelection)")
 //   if self.mTableView.selectedRow < 0, !self.mTableView.allowsEmptySelection, let rowCount = self.mRowCountCallBack? (), rowCount > 0 {
    if ensureNonEmpty, self.mTableView.selectedRow < 0, let rowCount = self.mRowCountCallBack? (), rowCount > 0 {
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
  //--- Scroll to make selection visible
    if self.mTableView.selectedRow >= 0 {
      self.mTableView.scrollRowToVisible (self.mTableView.selectedRow)
    }
  }

  //····················································································································

  var selectedRow : Int { return self.mTableView.selectedRow }

  //····················································································································
  //   NSTableViewDataSource protocol
  //····················································································································

  func numberOfRows (in tableView: NSTableView) -> Int {
    return self.mRowCountCallBack? () ?? 0
  }

  //····················································································································
  //   NSTableViewDelegate protocol
  //····················································································································

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn : NSTableColumn?,
                  row inRowIndex : Int) -> NSView? {
    if let tableColumn = inTableColumn as? AutoLayoutTableColumn {
      let view = tableColumn.configureTableCellView (forRowIndex: inRowIndex)
      return view
    }else{
      return nil
    }
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
    self.mRemoveButton?.enable (fromEnableBinding: !self.mTableView.selectedRowIndexes.isEmpty, self.mTableView.enabledBindingController)
  }

  //····················································································································

  func set (draggedTypes inDraggedTypes : [NSPasteboard.PasteboardType],
            dragFilterCallBack inFilterCallBack : @escaping ([URL]) -> Bool,
            dragConcludeCallBack inCallBack : @escaping ([URL]) -> Void) {
    self.mTableView.set (draggedTypes: inDraggedTypes, dragFilterCallBack: inFilterCallBack, dragConcludeCallBack: inCallBack)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// InternalAutoLayoutTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class InternalAutoLayoutTableView : NSTableView, EBUserClassNameProtocol {

  //····················································································································

  private var mDragConcludeCallBack : Optional < ([URL]) -> Void > = nil
  private var mDragFilterCallBack : Optional < ([URL]) -> Bool > = nil
//  private var mWidth : CGFloat? = nil
//  private var mHeight : CGFloat? = nil

  //····················································································································
  // INIT
  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (frame: NSRect (x: 0, y: 0, width: 10, height: 10))
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentHuggingPriority (.defaultLow, for: .vertical)
    self.controlSize = inSize.cocoaControlSize
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

//  func set (width inWidth : Int) {
//    self.mWidth = CGFloat (inWidth)
//  }

  //····················································································································

//  func set (height inHeight : Int) {
//    self.mHeight = CGFloat (inHeight)
//  }

  //····················································································································

//  override var intrinsicContentSize : NSSize {
//    var s = super.intrinsicContentSize
//    if let w = self.mWidth {
//      s.width = w
//    }
//    if let h = self.mHeight {
//      s.height = h
//    }
//    return s
//  }

  //····················································································································
  // MARK: Drag
  //····················································································································

  func set (draggedTypes inDraggedTypes : [NSPasteboard.PasteboardType],
            dragFilterCallBack inFilterCallBack : @escaping ([URL]) -> Bool,
            dragConcludeCallBack inConcludeCallBack : @escaping ([URL]) -> Void) {
    self.registerForDraggedTypes (inDraggedTypes)
    self.mDragConcludeCallBack = inConcludeCallBack
    self.mDragFilterCallBack = inFilterCallBack
  }

  //····················································································································

  override func draggingEntered (_ inSender : NSDraggingInfo) -> NSDragOperation {
    var dragOperation : NSDragOperation = []
    if let array = inSender.draggingPasteboard.readObjects (forClasses: [NSURL.self]) as? [URL],
      let ok = self.mDragFilterCallBack? (array) {
        dragOperation = ok ? .copy : []
    }
    return dragOperation
  }

  //····················································································································

  override func draggingUpdated (_ inSender : NSDraggingInfo) -> NSDragOperation {
    return self.draggingEntered (inSender)
  }

  //····················································································································

  override func draggingExited (_ inSender : NSDraggingInfo?) {
  }

  //····················································································································

  override func prepareForDragOperation (_ inSender : NSDraggingInfo) -> Bool {
    return true
  }

  //····················································································································

  override func performDragOperation (_ inSender : NSDraggingInfo) -> Bool {
    return self.draggingEntered (inSender) == .copy
  }

  //····················································································································

  override func concludeDragOperation (_ inSender : NSDraggingInfo?) {
    if let array = inSender?.draggingPasteboard.readObjects (forClasses: [NSURL.self]) as? [URL] {
      self.mDragConcludeCallBack? (array)
    }
  }

  //····················································································································
  //MARK:  $enabled binding
  //····················································································································

  private var mEnabledBindingController : EnabledBindingController? = nil
  var enabledBindingController : EnabledBindingController? { return self.mEnabledBindingController }

  //····················································································································

  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
