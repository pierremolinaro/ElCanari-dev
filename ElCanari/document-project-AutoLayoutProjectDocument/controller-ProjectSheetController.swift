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
  private var mStepper : AutoLayoutStepper? = nil
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

  func register (stepper inStepper : AutoLayoutStepper) {
    self.mStepper = inStepper
    inStepper.minValue = 0.0
 //   inStepper.maxValue = 0.0
    inStepper.increment = 1.0
    inStepper.target = self
    inStepper.action = #selector (Self.stepperAction (_:))
    self.updatePopUpButton ()
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private func updatePopUpButton () {
    self.mSheetPopUpButton?.removeAllItems ()
    let selectedSheet = self.mDocument?.rootObject.mSelectedSheet
    let sheets = self.mDocument?.rootObject.mSheets.values ?? []
    self.mStepper?.maxValue = Double (sheets.count - 1)
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
        self.mStepper?.doubleValue = Double (sheets.count - 1 - idx)
      }
      idx += 1
    }
  }

  //····················································································································

  @objc private func selectionDidChangeAction (_ inSender : NSMenuItem) {
    if let rootObject = self.mDocument?.rootObject {
      let selectedIndex = inSender.tag
      let sheets = rootObject.mSheets.values
      rootObject.mSelectedSheet = sheets [selectedIndex]
    }
  }

  //····················································································································

  @objc private func stepperAction (_ inSender : AutoLayoutStepper) {
    if let rootObject = self.mDocument?.rootObject {
      let idx = Int (inSender.doubleValue.rounded (.toNearestOrEven))
      let sheets = rootObject.mSheets.values
      rootObject.mSelectedSheet = sheets [sheets.count - 1 - idx]
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
