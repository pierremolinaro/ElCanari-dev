//
//  ProjectSheetController.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   ProjectSheetController
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ProjectSheetController : EBOutletEvent {

  //····················································································································
  // Properties
  //····················································································································

  private var mSheetPopUpButton : EBPopUpButton? = nil
  private var mSheetUpButton : EBButton? = nil
  private var mSheetDownButton : EBButton? = nil
  private var mDocument : CustomizedProjectDocument? = nil

  //····················································································································

  func register (document inDocument : CustomizedProjectDocument,
                 popup inPopUpButton : EBPopUpButton?,
                 sheetUp inSheetUpButton : EBButton?,
                 sheetDown inSheetDownButton : EBButton?) {
    self.mDocument = inDocument
    self.mSheetPopUpButton = inPopUpButton
    self.mSheetUpButton = inSheetUpButton
    self.mSheetDownButton = inSheetDownButton
  //--- Add sheet titles observer
    self.mEventCallBack = { [weak self] in self?.updatePopUpButton () }
    inDocument.rootObject.mSheets_property.addEBObserverOf_connexionWarnings (self)
    inDocument.rootObject.mSheets_property.addEBObserverOf_connexionErrors (self)
    inDocument.rootObject.mSheets_property.addEBObserverOf_mSheetTitle (self)
    inDocument.rootObject.mSelectedSheet_property.addEBObserver (self)
    self.mSheetUpButton?.target = self
    self.mSheetUpButton?.action = #selector (ProjectSheetController.sheetUpAction (_:))
    self.mSheetDownButton?.target = self
    self.mSheetDownButton?.action = #selector (ProjectSheetController.sheetDownAction (_:))
  }

  //····················································································································

  override func unregister () {
    super.unregister ()
    if let document = self.mDocument {
      document.rootObject.mSheets_property.removeEBObserverOf_mSheetTitle (self)
      document.rootObject.mSheets_property.removeEBObserverOf_connexionWarnings (self)
      document.rootObject.mSheets_property.removeEBObserverOf_connexionErrors (self)
      document.rootObject.mSelectedSheet_property.removeEBObserver (self)
    }
    self.mDocument = nil
    self.mSheetPopUpButton = nil
    self.mSheetUpButton = nil
    self.mSheetDownButton = nil
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private func updatePopUpButton () {
    self.mSheetPopUpButton?.removeAllItems ()
    self.mSheetUpButton?.isEnabled = false
    self.mSheetDownButton?.isEnabled = false
    let selectedSheet = self.mDocument?.rootObject.mSelectedSheet
    let sheets = self.mDocument?.rootObject.mSheets ?? []
    var idx = 0
    for sheet in sheets {
    //--- Build title
      let attributedString = NSMutableAttributedString ()
      var attributes : [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
      ]
      attributedString.append (NSAttributedString (string: "\(idx + 1)/\(sheets.count)", attributes: attributes))
      if sheet.mSheetTitle != "" {
        attributedString.append (NSAttributedString (string: ": \(sheet.mSheetTitle)", attributes: attributes))
      }
      if let errorCount = sheet.connexionErrors, errorCount > 0 {
        attributes [NSAttributedString.Key.foregroundColor] = NSColor.red
        attributedString.append (NSAttributedString (string: " — \(errorCount)", attributes: attributes))
      }
      if let warningCount = sheet.connexionWarnings, warningCount > 0 {
        attributes [NSAttributedString.Key.foregroundColor] = NSColor.orange
        attributedString.append (NSAttributedString (string: " — \(warningCount)", attributes: attributes))
      }
    //---
      self.mSheetPopUpButton?.addItem (withTitle: "")
      self.mSheetPopUpButton?.lastItem?.attributedTitle = attributedString
      self.mSheetPopUpButton?.lastItem?.tag = idx
      self.mSheetPopUpButton?.lastItem?.target = self
      self.mSheetPopUpButton?.lastItem?.action = #selector (ProjectSheetController.selectionDidChangeAction (_:))
      self.mSheetPopUpButton?.lastItem?.isEnabled = true
      if sheet === selectedSheet {
        self.mSheetPopUpButton?.selectItem (at: idx)
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
