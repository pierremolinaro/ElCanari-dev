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

final class ProjectSheetController : EBOutletEvent {

  //····················································································································
  // Properties
  //····················································································································

  private var mSheetPopUpButton : AutoLayoutPopUpButton? = nil
  private var mPreviousSheetButton : AutoLayoutButton? = nil
  private var mNextSheetButton : AutoLayoutButton? = nil
  private weak var mDocument : AutoLayoutProjectDocument? = nil

  //····················································································································

  func register (document inDocument : AutoLayoutProjectDocument,
                 popup inPopUpButton : AutoLayoutPopUpButton) {
    self.mDocument = inDocument
    self.mSheetPopUpButton = inPopUpButton
  //--- Add sheet titles observer
    self.mEventCallBack = { [weak self] in self?.updatePopUpButton () }
    inDocument.rootObject.mSheets_property.addEBObserverOf_connexionWarnings (self)
    inDocument.rootObject.mSheets_property.addEBObserverOf_connexionErrors (self)
    inDocument.rootObject.mSheets_property.addEBObserverOf_mSheetTitle (self)
    inDocument.rootObject.mSelectedSheet_property.addEBObserver (self)
  }

 //····················································································································

  func register (previousSheet inButton : AutoLayoutButton) {
    self.mPreviousSheetButton = inButton
    self.mPreviousSheetButton?.target = self
    self.mPreviousSheetButton?.action = #selector (Self.sheetUpAction (_:))

  }

 //····················································································································

  func register (nextSheet inButton : AutoLayoutButton) {
    self.mNextSheetButton = inButton
    self.mNextSheetButton?.target = self
    self.mNextSheetButton?.action = #selector (Self.sheetDownAction (_:))
  }

  //····················································································································

//  override func unregister () {
//    super.unregister ()
//    if let document = self.mDocument {
//      document.rootObject.mSheets_property.removeEBObserverOf_mSheetTitle (self)
//      document.rootObject.mSheets_property.removeEBObserverOf_connexionWarnings (self)
//      document.rootObject.mSheets_property.removeEBObserverOf_connexionErrors (self)
//      document.rootObject.mSelectedSheet_property.removeEBObserver (self)
//    }
//    self.mDocument = nil
//    self.mSheetPopUpButton = nil
//    self.mPreviousSheetButton = nil
//    self.mNextSheetButton = nil
//  }

  //····················································································································
  // MARK: -
  //····················································································································

  private func updatePopUpButton () {
    self.mSheetPopUpButton?.removeAllItems ()
    self.mPreviousSheetButton?.isEnabled = false
    self.mNextSheetButton?.isEnabled = false
    let selectedSheet = self.mDocument?.rootObject.mSelectedSheet
    let sheets = self.mDocument?.rootObject.mSheets.values ?? []
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
      self.mSheetPopUpButton?.lastItem?.action = #selector (Self.selectionDidChangeAction (_:))
      self.mSheetPopUpButton?.lastItem?.isEnabled = true
      if sheet === selectedSheet {
        self.mSheetPopUpButton?.selectItem (at: idx)
        self.mPreviousSheetButton?.isEnabled = idx > 0
        self.mNextSheetButton?.isEnabled = idx < (sheets.count - 1)
      }
      idx += 1
    }
  }

  //····················································································································

  @objc func selectionDidChangeAction (_ inSender : NSMenuItem) {
    let selectedIndex = inSender.tag
    let sheets = self.mDocument?.rootObject.mSheets.values ?? []
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
