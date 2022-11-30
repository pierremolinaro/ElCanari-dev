//
//  AutoLayoutOutlineView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/11/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutOutlineView : AutoLayoutVerticalStackView, NSOutlineViewDataSource, NSOutlineViewDelegate {

  //····················································································································

  private final let mScrollView = AutoLayoutScrollView ()
  private final let mOutlineView : InternalAutoLayoutOutlineView
  private final var mAddButton : AutoLayoutButton? = nil
  private final var mRemoveButton : AutoLayoutButton? = nil
  private final weak var mDelegate : AutoLayoutOutlineViewDelegate? = nil // SHOULD BE WEAK
  private final var mRowCountCallBack : Optional < () -> Int > = nil

  private final var mTransmitSelectionChangeToDelegate = true

  //····················································································································

  init (size inSize : EBControlSize, addControlButtons inAddControlButtons : Bool) {
    self.mOutlineView = InternalAutoLayoutOutlineView (size: inSize)
    super.init ()

    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.mOutlineView.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.mOutlineView.setContentCompressionResistancePriority (.defaultHigh, for: .vertical)

  //--- Configure table view
    self.mOutlineView.controlSize = inSize.cocoaControlSize
    self.mOutlineView.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.mOutlineView.controlSize))
    self.mOutlineView.focusRingType = .none
    self.mOutlineView.isEnabled = true
    self.mOutlineView.delegate = self
    self.mOutlineView.dataSource = self
    self.mOutlineView.gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
    self.mOutlineView.usesAlternatingRowBackgroundColors = true
    self.mOutlineView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
    self.mOutlineView.usesAutomaticRowHeights = true
    _ = self.setIntercellSpacing (horizontal: 5, vertical: 5)
  //--- Configure scroll view
    self.mScrollView.translatesAutoresizingMaskIntoConstraints = false
    self.mScrollView.hasVerticalScroller = true
    self.mScrollView.borderType = .bezelBorder
    self.mScrollView.documentView = self.mOutlineView
  //---
    _ = self.appendView (self.mScrollView)
    if inAddControlButtons {
      let hStack = AutoLayoutHorizontalStackView ()
      let addButton = AutoLayoutButton (title: "+", size: inSize)
        .bind_run (target: self, selector: #selector (Self.addEntryAction (_:)))
      self.mAddButton = addButton
      _ = hStack.appendView (addButton)
      let removeButton = AutoLayoutButton (title: "-", size: inSize)
        .bind_run (target: self, selector: #selector (Self.removeSelectedEntriesAction (_:)))
      self.mRemoveButton = removeButton
      _ = hStack.appendView (removeButton)
      _ = hStack.appendFlexibleSpace ()
      _ = self.appendView (hStack)
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
                        delegate inDelegate : AutoLayoutOutlineViewDelegate?) {
    // Swift.print ("inAllowsEmptySelection \(inAllowsEmptySelection) inAllowsMultipleSelection \(inAllowsMultipleSelection)")
    self.mOutlineView.allowsEmptySelection = inAllowsEmptySelection
    self.mOutlineView.allowsMultipleSelection = inAllowsMultipleSelection
    self.mRowCountCallBack = inRowCountCallBack
    self.mDelegate = inDelegate
  }

  //····················································································································

  final func noHeaderView () -> Self {
    self.mOutlineView.headerView = nil
    self.mOutlineView.cornerView = nil
    return self
  }

  //····················································································································

  final func setIntercellSpacing (horizontal inX : Int, vertical inY : Int) -> Self {
    self.mOutlineView.intercellSpacing = NSSize (width: inX, height: inY)
    return self
  }

  //····················································································································

  final func set (hasHorizontalGrid inFlag : Bool) -> Self {
    if inFlag {
      self.mOutlineView.gridStyleMask.insert (.solidHorizontalGridLineMask)
    }else{
      self.mOutlineView.gridStyleMask.remove (.solidHorizontalGridLineMask)
    }
    return self
  }
  
  //····················································································································

  final func set (usesAlternatingRowBackgroundColors inFlag : Bool) -> Self {
    self.mOutlineView.usesAlternatingRowBackgroundColors = inFlag
    return self
  }

  //····················································································································

  @objc final func addEntryAction (_ inUnusedSender : Any?) {
    self.mDelegate?.outlineViewDelegate_addEntry ()
  }

  //····················································································································

  @objc final func removeSelectedEntriesAction (_ inUnusedSender : Any?) {
    self.mDelegate?.outlineViewDelegate_removeSelectedEntries ()
  }

  //····················································································································

  final var columnCount : Int {
    return self.mOutlineView.tableColumns.count
  }

  //····················································································································

  final var font : NSFont? {
    return self.mOutlineView.font
  }

  //····················································································································

  final var controlSize : NSControl.ControlSize {
    return self.mOutlineView.controlSize
  }

  //····················································································································

  final func appendTableColumn (_ inColumn : AutoLayoutTableColumn) {
  //--- Add Column
    self.mOutlineView.addTableColumn (inColumn)
  //--- Update table view sort descriptors
    if let s = inColumn.sortDescriptorPrototype {
      self.mOutlineView.sortDescriptors.append (s)
    }
  }

  //····················································································································

  final func scrollRowToVisible (row inRow : Int) {
    self.mOutlineView.scrollRowToVisible (inRow)
  }

  //····················································································································

  final func sortAndReloadData () {
    // Swift.print ("AutoLayoutOutlineView reloads data")
  //--- Current selected row
    let currentSelectedRow = self.mOutlineView.selectedRow // < 0 if no selected row
    // Swift.print ("currentSelectedRow \(currentSelectedRow)")
  //--- Reload; reloading change selection, so we temporary disable transmitting selection change to delegate
    self.mTransmitSelectionChangeToDelegate = false
    self.mDelegate?.outlineViewDelegate_beginSorting ()
    for descriptor in self.mOutlineView.sortDescriptors.reversed () {
      for tableColumn in self.mOutlineView.tableColumns {
        if let column = tableColumn as? AutoLayoutTableColumn, column.identifier.rawValue == descriptor.key {
          column.mSortDelegate? (descriptor.ascending)
        }
      }
    }
    self.mDelegate?.outlineViewDelegate_endSorting ()
    self.mOutlineView.reloadData ()
    self.mTransmitSelectionChangeToDelegate = true
  //--- Restore Selection
    if let selectedObjectIndexes = self.mDelegate?.outlineViewDelegate_indexesOfSelectedObjects () {
      self.mOutlineView.selectRowIndexes (selectedObjectIndexes, byExtendingSelection: false)
      if selectedObjectIndexes.isEmpty {
        self.mDelegate?.outlineViewDelegate_selectionDidChange (selectedRows: IndexSet ())
      }
    }else{
      self.mOutlineView.selectRowIndexes (IndexSet (), byExtendingSelection: false)
    }
  //--- Ensure selection non empty ?
    let ensureNonEmpty = (currentSelectedRow >= 0) || !self.mOutlineView.allowsEmptySelection
    // Swift.print ("self.mOutlineView.selectedRow \(self.mOutlineView.selectedRow), \(self.mOutlineView.allowsEmptySelection)")
    if ensureNonEmpty, self.mOutlineView.selectedRow < 0, let rowCount = self.mRowCountCallBack? (), rowCount > 0 {
      if currentSelectedRow >= 0 {
        if currentSelectedRow < rowCount {
          self.mOutlineView.selectRowIndexes (IndexSet (integer: currentSelectedRow), byExtendingSelection: false)
        }else{
          self.mOutlineView.selectRowIndexes (IndexSet (integer: rowCount - 1), byExtendingSelection: false)
        }
      }else{
        self.mOutlineView.selectRowIndexes (IndexSet (integer: 0), byExtendingSelection: false)
      }
    }
  //--- Scroll to make selection visible
    if self.mOutlineView.selectedRow >= 0 {
      self.mOutlineView.scrollRowToVisible (self.mOutlineView.selectedRow)
    }
  }

  //····················································································································

  final var selectedRow : Int { return self.mOutlineView.selectedRow }

  //····················································································································
  //   NSOutlineViewDataSource protocol
  //····················································································································

//  @MainActor final func numberOfRows (in tableView: NSTableView) -> Int {
//    return self.mRowCountCallBack? () ?? 0
//  }

  @MainActor final func outlineView (_ outlineView: NSOutlineView,
                                     child index: Int,
                                     ofItem item: Any?) -> Any {
    return 0
  }

  //····················································································································

  @MainActor final func outlineView (_ outlineView: NSOutlineView,
                                     numberOfChildrenOfItem item: Any?) -> Int {
    return 0
  }

  //····················································································································

  @MainActor final func outlineView (_ outlineView: NSOutlineView,
                                     isItemExpandable item: Any) -> Bool {
    return false
  }

  //····················································································································

  @MainActor final func outlineView (_ outlineView: NSOutlineView,
                                     objectValueFor tableColumn: NSTableColumn?,
                                     byItem item: Any?) -> Any? {
    return nil
  }

  //····················································································································
  //   NSTableViewDelegate protocol
  //····················································································································

//  @MainActor final func tableView (_ tableView : NSTableView,
//                        viewFor inTableColumn : NSTableColumn?,
//                        row inRowIndex : Int) -> NSView? {
//    if let tableColumn = inTableColumn as? AutoLayoutTableColumn {
//      let view = tableColumn.configureTableCellView (forRowIndex: inRowIndex)
//      return view
//    }else{
//      return nil
//    }
//  }

  //····················································································································
  //    outlineView:sortDescriptorsDidChange: NSOutlineViewDataSource delegate
  //····················································································································

//  final func outlineView (_ outlineView : NSOutlineView,
//                          sortDescriptorsDidChange oldDescriptors : [NSSortDescriptor]) {
//    self.sortAndReloadData ()
//  }

  //····················································································································
  //    T A B L E V I E W    D E L E G A T E : outlineViewSelectionDidChange:
  //····················································································································

  final func outlineViewSelectionDidChange (_ notification : Notification) {
    if mTransmitSelectionChangeToDelegate {
      self.mDelegate?.outlineViewDelegate_selectionDidChange (selectedRows: self.mOutlineView.selectedRowIndexes)
    }
    self.mRemoveButton?.enable (fromEnableBinding: !self.mOutlineView.selectedRowIndexes.isEmpty, self.mOutlineView.enabledBindingController)
  }

  //····················································································································

  final func set (draggedTypes inDraggedTypes : [NSPasteboard.PasteboardType],
            dragFilterCallBack inFilterCallBack : @escaping ([URL]) -> Bool,
            dragConcludeCallBack inCallBack : @escaping ([URL]) -> Void) {
    self.mOutlineView.set (draggedTypes: inDraggedTypes, dragFilterCallBack: inFilterCallBack, dragConcludeCallBack: inCallBack)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// InternalAutoLayoutOutlineView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class InternalAutoLayoutOutlineView : NSOutlineView {

  //····················································································································

  private var mDragConcludeCallBack : Optional < ([URL]) -> Void > = nil
  private var mDragFilterCallBack : Optional < ([URL]) -> Bool > = nil

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

  func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
