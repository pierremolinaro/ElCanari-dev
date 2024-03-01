//
//  ProjectSheetController.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   ProjectSheetController
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class ProjectSheetController : EBOutletEvent {

  //································································································
  // Properties
  //································································································

  private var mSheetPopUpButtonArray = EBWeakReferenceArray <AutoLayoutPopUpButton> ()
  private var mMoveSheetUpButtonArray = EBWeakReferenceArray <AutoLayoutButton> ()
  private var mMoveSheetDownButtonArray = EBWeakReferenceArray <AutoLayoutButton> ()
  private var mStepperArray = EBWeakReferenceArray <AutoLayoutStepper> ()
  private weak var mDocument : AutoLayoutProjectDocument? = nil // SHOULD BE WEAK

  //································································································

  func register (document inDocument : AutoLayoutProjectDocument,
                 popup inPopUpButton : AutoLayoutPopUpButton) {
    self.mDocument = inDocument
    self.mSheetPopUpButtonArray.append (inPopUpButton)
  //--- Add sheet titles observer
    self.mEventCallBack = { [weak self] in self?.updatePopUpButtonAndSteppers () }
    inDocument.rootObject.mSheets_property.toMany_schematicConnexionWarnings_StartsBeingObserved (by: self)
    inDocument.rootObject.mSheets_property.toMany_schematicConnexionErrors_StartsBeingObserved (by: self)
    inDocument.rootObject.mSheets_property.toMany_mSheetTitle_StartsBeingObserved (by: self)
    inDocument.rootObject.mSelectedSheet_property.startsBeingObserved (by: self)
  }

 //····················································································································

  func register (stepper inStepper : AutoLayoutStepper) {
    self.mStepperArray.append (inStepper)
    inStepper.minValue = 0.0
 //   inStepper.maxValue = 0.0
    inStepper.increment = 1.0
    inStepper.target = self
    inStepper.action = #selector (Self.stepperAction (_:))
    self.updatePopUpButtonAndSteppers ()
  }

 //····················································································································

  func register (moveSheetUpButton inButton : AutoLayoutButton) {
    self.mMoveSheetUpButtonArray.append (inButton)
    inButton.title = UP_ARROW_STRING
    inButton.target = self
    inButton.action = #selector (Self.moveUpAction (_:))
  }

 //····················································································································

  func register (moveSheetDownButton inButton : AutoLayoutButton) {
    self.mMoveSheetDownButtonArray.append (inButton)
    inButton.title = DOWN_ARROW_STRING
    inButton.target = self
    inButton.action = #selector (Self.moveDownAction (_:))
  }

  //································································································
  // MARK: -
  //································································································

  private func updatePopUpButtonAndSteppers () {
    let selectedSheet = self.mDocument?.rootObject.mSelectedSheet
    let sheets = self.mDocument?.rootObject.mSheets.values ?? []
    for popUpButton in self.mSheetPopUpButtonArray.values {
      popUpButton.removeAllItems ()
      for stepper in self.mStepperArray.values {
        stepper.maxValue = Double (sheets.count - 1)
      }
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
        if let errorCount = sheet.schematicConnexionErrors, errorCount > 0 {
          attributes [NSAttributedString.Key.foregroundColor] = NSColor.red
          attributedString.append (NSAttributedString (string: " — \(errorCount)", attributes: attributes))
        }
        if let warningCount = sheet.schematicConnexionWarnings, warningCount > 0 {
          attributes [NSAttributedString.Key.foregroundColor] = NSColor.orange
          attributedString.append (NSAttributedString (string: " — \(warningCount)", attributes: attributes))
        }
      //---
        popUpButton.addItem (withTitle: "")
        popUpButton.lastItem?.attributedTitle = attributedString
        popUpButton.lastItem?.tag = idx
        popUpButton.lastItem?.target = self
        popUpButton.lastItem?.action = #selector (Self.selectionDidChangeAction (_:))
        popUpButton.lastItem?.isEnabled = true
        if sheet === selectedSheet {
          popUpButton.selectItem (at: idx)
          for stepper in self.mStepperArray.values {
            stepper.doubleValue = Double (sheets.count - 1 - idx)
          }
          self.configureMoveButtons (withIndex: idx, sheetCount: sheets.count)
        }
        idx += 1
      }
    }
  }

  //································································································

  private func selectSheet (atIndex inIndex : Int) {
    if let rootObject = self.mDocument?.rootObject {
      let sheets = rootObject.mSheets.values
      rootObject.mSelectedSheet = sheets [inIndex]
      self.configureMoveButtons (withIndex: inIndex, sheetCount: sheets.count)
    }
  }

  //································································································

  private func configureMoveButtons (withIndex inIndex : Int, sheetCount inSheetCount : Int) {
    for button in self.mMoveSheetUpButtonArray.values {
      button.isEnabled = inIndex > 0
      button.tag = inIndex
      button.toolTip = (inIndex > 0)
        ? "Move sheet to \(inIndex)/\(inSheetCount)"
        : "Disabled, selected sheet is the first one"
    }
    for button in  self.mMoveSheetDownButtonArray.values {
      button.isEnabled = inIndex < (inSheetCount - 1)
      button.tag = inIndex
      button.toolTip = (inIndex < (inSheetCount - 1))
        ? "Move sheet to \(inIndex + 2)/\(inSheetCount)"
        : "Disabled, selected sheet is the last one"
      }
  }

  //································································································

  @objc private func selectionDidChangeAction (_ inSender : NSMenuItem) {
    self.selectSheet (atIndex: inSender.tag)
  }

  //································································································

  @objc private func stepperAction (_ inSender : AutoLayoutStepper) {
    if let rootObject = self.mDocument?.rootObject {
      let idx = Int (inSender.doubleValue.rounded (.toNearestOrEven))
      let sheets = rootObject.mSheets.values
      rootObject.mSelectedSheet = sheets [sheets.count - 1 - idx]
    }
  }

  //································································································

  @objc private func moveUpAction (_ inSender : AutoLayoutButton) {
    if let rootObject = self.mDocument?.rootObject {
      let selectedIndex = inSender.tag
      var sheets = rootObject.mSheets.values
      let selectedSheet = sheets [selectedIndex]
      let previousSheet = sheets [selectedIndex - 1]
      sheets [selectedIndex] = previousSheet
      sheets [selectedIndex - 1] = selectedSheet
      rootObject.mSheets = EBReferenceArray (sheets)
      self.updatePopUpButtonAndSteppers ()
    }
  }

  //································································································

  @objc private func moveDownAction (_ inSender : AutoLayoutButton) {
    if let rootObject = self.mDocument?.rootObject {
      let selectedIndex = inSender.tag
      var sheets = rootObject.mSheets.values
      let selectedSheet = sheets [selectedIndex]
      let nextSheet = sheets [selectedIndex + 1]
      sheets [selectedIndex] = nextSheet
      sheets [selectedIndex + 1] = selectedSheet
      rootObject.mSheets = EBReferenceArray (sheets)
      self.updatePopUpButtonAndSteppers ()
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
