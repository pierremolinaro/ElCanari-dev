//
//  CanariSheetPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariSheetPopUpButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariSheetPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································
  // Outlet
  //····················································································································

  @IBOutlet var mSheetUpButton : EBButton? = nil
  @IBOutlet var mSheetDownButton : EBButton? = nil

  //····················································································································

  private var mSheetController : EBOutletEvent? = nil

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private var mDocument : CustomizedProjectDocument? = nil

  //····················································································································

  func register (document inDocument : CustomizedProjectDocument) {
    self.mDocument = inDocument
  //--- Add sheet titles observer
    let sheetController = EBOutletEvent ()
    self.mSheetController = sheetController
    sheetController.mEventCallBack = { [weak self] in self?.updatePopUpButton () }
    inDocument.rootObject.mSheets_property.addEBObserverOf_mSheetTitle (sheetController)
    inDocument.rootObject.mSelectedSheet_property.addEBObserver (sheetController)
    self.mSheetUpButton?.target = self
    self.mSheetUpButton?.action = #selector (CanariSheetPopUpButton.sheetUpAction (_:))
    self.mSheetDownButton?.target = self
    self.mSheetDownButton?.action = #selector (CanariSheetPopUpButton.sheetDownAction (_:))
  }

  //····················································································································

  func unregister () {
    if let document = self.mDocument, let sheetController = self.mSheetController {
      document.rootObject.mSheets_property.removeEBObserverOf_mSheetTitle (sheetController)
      document.rootObject.mSelectedSheet_property.removeEBObserver (sheetController)
    }
    self.mDocument = nil
    self.mSheetController = nil
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private func updatePopUpButton () {
    self.removeAllItems ()
    self.mSheetUpButton?.isEnabled = false
    self.mSheetDownButton?.isEnabled = false
    let selectedSheet = self.mDocument?.rootObject.mSelectedSheet
    let sheets = self.mDocument?.rootObject.mSheets ?? []
    var idx = 0
    for sheet in sheets {
      self.addItem (withTitle: "\(sheet.mSheetTitle) (\(idx + 1)/\(sheets.count))")
      self.lastItem?.tag = idx
      self.lastItem?.target = self
      self.lastItem?.action = #selector (CanariSheetPopUpButton.selectionDidChangeAction (_:))
      self.lastItem?.isEnabled = true
      if sheet === selectedSheet {
        self.selectItem (at: idx)
        self.mSheetUpButton?.isEnabled = idx > 0
        self.mSheetDownButton?.isEnabled = idx < (sheets.count - 1)
      }
      idx += 1
    }
  }

  //····················································································································

  @objc func selectionDidChangeAction (_ inSender : NSMenuItem) {
    let selectedIndex = inSender.tag
    let sheets = self.mDocument?.rootObject.mSheets ?? []
    self.mDocument?.rootObject.mSelectedSheet = sheets [selectedIndex]
  }


  //····················································································································

  @objc func sheetUpAction (_ inSender : EBButton) {
    if let rootObject = self.mDocument?.rootObject,
       let selectedSheet = rootObject.mSelectedSheet,
       let idx = rootObject.mSheets.firstIndex (of: selectedSheet) {
        rootObject.mSheets.remove (at: idx)
        rootObject.mSheets.insert (selectedSheet, at: idx - 1)
    }
  }

  //····················································································································

  @objc func sheetDownAction (_ inSender : EBButton) {
    if let rootObject = self.mDocument?.rootObject,
       let selectedSheet = rootObject.mSelectedSheet,
       let idx = rootObject.mSheets.firstIndex (of: selectedSheet) {
        rootObject.mSheets.remove (at: idx)
        rootObject.mSheets.insert (selectedSheet, at: idx + 1)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
