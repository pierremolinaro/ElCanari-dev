//
//  controller-CanariLibraryUpdateController.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariLibraryUpdateController : EBObject {

  let mArrayController = NSArrayController ()

  var mCurrentActionArray : [LibraryOperationElement]
  var mCurrentParallelActionCount = 0
  var mNextActionIndex = 0 // Index of mActionArray

  let mActionArray : [LibraryOperationElement]
  let mRepositoryFileDictionary : [String : CanariLibraryFileDescriptor]
  let mLogTextView : NSTextView

  var logTextView : NSTextView { return self.mLogTextView }

  //····················································································································
  //   Init
  //····················································································································

  init (_ inActionArray : [LibraryOperationElement],
        _ inRepositoryFileDictionary : [String : CanariLibraryFileDescriptor],
        _ inLogTextView : NSTextView) {
    mCurrentActionArray = inActionArray
    mActionArray = inActionArray
    mRepositoryFileDictionary = inRepositoryFileDictionary
    mLogTextView = inLogTextView
    super.init ()
  }

  //····················································································································

  override init () {
    mCurrentActionArray = []
    mActionArray = []
    mRepositoryFileDictionary = [:]
    mLogTextView = NSTextView ()
    super.init ()
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
  //  Cocoa bindings
  //····················································································································

  func bind () {
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "name"))?.bind (
        NSBindingName(rawValue: "value"),
        to:self.mArrayController,
        withKeyPath:"arrangedObjects.relativePath",
        options:nil
      )
      tableView.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "action"))?.bind (
        NSBindingName(rawValue: "value"),
        to:self.mArrayController,
        withKeyPath:"arrangedObjects.actionName",
        options:nil
      )
      self.mArrayController.content = self.mCurrentActionArray
    }
  }

  //····················································································································

  func unbind () { //--- Remove bindings
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "name"))?.unbind (NSBindingName(rawValue: "value"))
      tableView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "action"))?.unbind (NSBindingName(rawValue: "value"))
      mArrayController.content = nil
    }
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
  //   elementActionDidEnd
  //····················································································································

  func elementActionDidEnd (_ inElement : LibraryOperationElement, _ inErrorCode : Int32) {
    if (self.mErrorCode == 0) && (inErrorCode != 0) {
       mErrorCode = inErrorCode
    }
  //--- Decrement parallel action count
    self.mCurrentParallelActionCount -= 1
  //--- Remove corresponding entry in table view
    if let idx = self.mCurrentActionArray.index (of: inElement) {
      self.mCurrentActionArray.remove (at: idx)
      self.mArrayController.content = self.mCurrentActionArray
    }
  //--- Update progress indicator
    self.updateProgressIndicator ()
  //--- Update remaining operation count
    if self.mCurrentActionArray.count == 0 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "Commiting changes…"
    }else if self.mCurrentActionArray.count == 1 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
   }else{
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(self.mCurrentActionArray.count) elements to update"
    }
  //--- Launch next action, if any
    if self.mNextActionIndex < self.mActionArray.count {
      self.mNextActionIndex += 1
      self.mCurrentParallelActionCount += 1
      self.mActionArray [self.mNextActionIndex - 1].beginAction (self)
    }else if self.mCurrentParallelActionCount == 0 { // Last download did end
      DispatchQueue.main.async { commitAllActions (self.mActionArray, self.mRepositoryFileDictionary, self.mLogTextView) }
    }
  }

  //····················································································································

  func updateProgressIndicator () {
    var progressCurrentValue = 0.0
    for action in self.mActionArray {
      progressCurrentValue += action.currentIndicatorValue
    }
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = progressCurrentValue
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
