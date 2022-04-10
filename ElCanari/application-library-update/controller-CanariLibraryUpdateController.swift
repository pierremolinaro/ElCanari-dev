//
//  controller-CanariLibraryUpdateController.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let parallelDownloadCount = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariLibraryUpdateController : EBObjcBaseObject, AutoLayoutTableViewDelegate {

  private var mCurrentActionArray : [LibraryOperationElement]
  private var mCurrentParallelActionCount = 0
  private var mNextActionIndex = 0 // Index of mActionArray

  private let mActionArray : [LibraryOperationElement]
  private let mNewRepositoryFileDictionary : [String : CanariLibraryFileDescriptor]
  private let mLogTextView : AutoLayoutStaticTextView

  //····················································································································
  //   Properties
  //····················································································································

  private let mLibraryUpdatePanel : NSPanel
  private let mProgressIndicator : AutoLayoutProgressIndicator
  private let mInformativeText : AutoLayoutLabel
  private let mTableView : AutoLayoutTableView
  private let mUpDateButton : AutoLayoutButton
  private let mCancelButton : AutoLayoutSheetCancelButton

  //····················································································································
  //   Init
  //····················································································································

  init (_ inActionArray : [LibraryOperationElement],
        _ inNewLocalDescriptionDictionary : [String : CanariLibraryFileDescriptor],
        _ inLogTextView : AutoLayoutStaticTextView,
        _ inProgressMaxValue : Double,
        _ inInformativeText : String) {
    self.mCurrentActionArray = inActionArray
    self.mActionArray = inActionArray
    self.mNewRepositoryFileDictionary = inNewLocalDescriptionDictionary
    self.mLogTextView = inLogTextView
  //--- Build Panel
    self.mLibraryUpdatePanel = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 800, height: 400),
      styleMask: [.titled, .resizable],
      backing: .buffered,
      defer: false
    )
    self.mLibraryUpdatePanel.title = "Library Update"
    self.mLibraryUpdatePanel.hasShadow = true
  //--- Main view
    let mainView = AutoLayoutVerticalStackView ().set (margins: 20)
  //--- Informative text
    self.mInformativeText = AutoLayoutLabel (bold: false, size: .regular).set (alignment: .left).expandableWidth ()
    self.mInformativeText.stringValue = inInformativeText
    mainView.appendView (self.mInformativeText)
  //--- Table view
    self.mTableView = AutoLayoutTableView (size: .small, addControlButtons: false).expandableWidth ()
    mainView.appendView (self.mTableView)
  //--- Last line
    let lastLine = AutoLayoutHorizontalStackView () //.expandableWidth ()
    self.mProgressIndicator = AutoLayoutProgressIndicator ()
    self.mProgressIndicator.minValue = 0.0
    self.mProgressIndicator.maxValue = inProgressMaxValue
    self.mProgressIndicator.doubleValue = 0.0
    self.mProgressIndicator.isIndeterminate = false
    lastLine.appendView (self.mProgressIndicator)
    lastLine.appendFlexibleSpace ()
    self.mCancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular, sheet: self.mLibraryUpdatePanel, isInitialFirstResponder: false)
    lastLine.appendView (self.mCancelButton)
    self.mUpDateButton = AutoLayoutButton (title: "Update All", size: .regular)
    lastLine.appendView (self.mUpDateButton)
    mainView.appendView (lastLine)
  //--- Set autolayout view to panel
    self.mLibraryUpdatePanel.contentView = AutoLayoutViewByPrefixingAppIcon (prefixedView: AutoLayoutWindowContentView (view: mainView))
  //--- Super init
    super.init ()
  //--- Configure tableview
    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in self?.mCurrentActionArray.count ?? 0 },
      delegate: self
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in self?.mCurrentActionArray [$0].mRelativePath },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Name",
      minWidth: 440,
      maxWidth: 2_000,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in self?.mCurrentActionArray [$0].actionName },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "Action",
      minWidth: 200,
      maxWidth: 2_000,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.sortAndReloadData ()
  //--- Configure buttons
    self.mCancelButton.target = self
    self.mCancelButton.action = #selector (Self.cancelLibraryUpdateAction (_:))
    self.mUpDateButton.target = self
    self.mUpDateButton.action = #selector (Self.startLibraryUpdateAction (_:))
  //--- Show library update window
    self.mLibraryUpdatePanel.makeKeyAndOrderFront (nil)
  }

  //····················································································································
  //   Handling error or cancel
  //····················································································································

  private var mErrorCode : Int32 = 0 // No error

  //····················································································································

  var shouldCancel : Bool { return mErrorCode != 0 }

  //····················································································································

  func cancel () {
    self.mErrorCode = -1
  }

  //····················································································································
  //  AutoLayoutTableViewDelegate methods
  //····················································································································

  func tableViewSelectionDidChange (selectedRows inSelectedRows: IndexSet) {
  }

  func indexesOfSelectedObjects() -> IndexSet {
    return IndexSet ()
  }

  func addEntry () {
  }

  func removeSelectedEntries () {
  }

  func beginSorting() {
  }

  func endSorting() {
  }

  //····················································································································
  //   launchElementDownload
  //····················································································································

  func launchElementDownload () {
    if self.mNextActionIndex < self.mActionArray.count {
      self.mNextActionIndex += 1
      self.mCurrentParallelActionCount += 1
      self.mActionArray [self.mNextActionIndex - 1].beginAction (self)
    }
  }

  //····················································································································
  //   elementActionDidEnd (runs in main thread)
  //····················································································································

  func elementActionDidEnd (_ inElement : LibraryOperationElement, _ inErrorCode : Int32) {
    if !Thread.isMainThread {
      Swift.print ("\(#file),\(#line): Not in main thread!")
    }
    if (self.mErrorCode == 0) && (inErrorCode != 0) {
       mErrorCode = inErrorCode
    }
  //--- Decrement parallel action count
    self.mCurrentParallelActionCount -= 1
  //--- Remove corresponding entry in table view
    if let idx = self.mCurrentActionArray.firstIndex (of: inElement) {
      self.mCurrentActionArray.remove (at: idx)
      self.mTableView.sortAndReloadData ()
//      DispatchQueue.main.async { self.mArrayController.content = self.mCurrentActionArray }
    }
  //--- Update progress indicator
    self.updateProgressIndicator ()
  //--- Update remaining operation count
    if self.mCurrentActionArray.count == 0 {
      self.mInformativeText.stringValue = "Commiting changes…"
    }else if self.mCurrentActionArray.count == 1 {
      self.mInformativeText.stringValue = "1 element to update"
    }else{
      self.mInformativeText.stringValue = "\(self.mCurrentActionArray.count) elements to update"
    }
  //--- Launch next action, if any
    if self.mNextActionIndex < self.mActionArray.count {
      self.mNextActionIndex += 1
      self.mCurrentParallelActionCount += 1
      let action = self.mActionArray [self.mNextActionIndex - 1]
      DispatchQueue.main.async { action.beginAction (self) }
    }else if self.mCurrentParallelActionCount == 0 { // Last download did end
      DispatchQueue.main.async { commitAllActions (self.mActionArray, self.mNewRepositoryFileDictionary, self.mLogTextView) }
    //  commitAllActions (self.mActionArray, self.mNewRepositoryFileDictionary, self.mLogTextView)
    }
  }

  //····················································································································

  func updateProgressIndicator () {
    if !Thread.isMainThread {
      Swift.print ("\(#file),\(#line): Not in main thread!")
    }
    var progressCurrentValue = 0.0
    for action in self.mActionArray {
      progressCurrentValue += action.currentIndicatorValue
    }
    self.mProgressIndicator.doubleValue = progressCurrentValue
  }

  //····················································································································

  @objc func cancelLibraryUpdateAction (_ inSender : AnyObject) {
   self.mLibraryUpdatePanel.orderOut (nil)
  //--- Cancel current downloadings
    self.cancel ()
    self.startLibraryUpdateAction (inSender)
  }

  //····················································································································

  @objc func startLibraryUpdateAction (_ inSender : AnyObject) {
    self.mUpDateButton.isEnabled = false
  //--- Launch parallel downloads
    for _ in 1...parallelDownloadCount {
      self.launchElementDownload ()
    }
  }

  //····················································································································

  func orderOutLibraryUpdatePanel () {
    self.mLibraryUpdatePanel.orderOut (nil)
  }

  //····················································································································

  func panelForSheet () -> NSPanel {
    return self.mLibraryUpdatePanel
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
