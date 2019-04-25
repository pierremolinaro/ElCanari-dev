//
//  extension-ProjectDocument-rename-component.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  @objc @IBAction func renameComponentAction (_ sender : NSObject?) { // Targeted in IB
    let selectedComponents = self.mComponentController.selectedArray_property.propval
    if selectedComponents.count == 1, let window = self.windowForSheet, let panel = self.mRenameComponentPanel {
    //--- Component current settings
      let component = selectedComponents [0]
      self.mSelectedComponentForRenaming = component
      self.mComponentCurrentIndex = component.mNameIndex
      self.mComponentCurrentPrefix = component.mNamePrefix
      self.mComponentNewIndex = component.mNameIndex
      self.mComponentNewPrefix = component.mNamePrefix
      self.updateRenameComponentValidationButton ()
      self.mCurrentComponentNameTextField?.stringValue = self.mComponentCurrentPrefix + ":\(self.mComponentCurrentIndex)"
      self.mRenameComponentErrorMessageTextField?.stringValue = ""
    //--- Prefix Combo box
      let currentPrefixSet = self.getComponentNamePrefixes ()
      self.populatePrefixComboBox (currentPrefixSet, self.mComponentCurrentPrefix)
      self.mRenameComponentPrefixComboxBox?.textDidChangeCallBack = { [weak self] (_ : CanariComboBox) in self?.renameComponentComboBoxAction () }
      self.mRenameComponentPrefixComboxBox?.isContinuous = true
    //--- Name index pop up
      self.populateIndexesPopupButton (self.mComponentCurrentIndex)
      self.mRenameComponentIndexesPopUpButton?.target = self
      self.mRenameComponentIndexesPopUpButton?.action = #selector (CustomizedProjectDocument.renameComponentIndexPopUpButtonAction (_:))
    //--- Sheet
      self.mRenameComponentValidationButton?.isEnabled = true
      window.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop {
          self.performRenameComponent ()
        }
      }
    }
  }

  //····················································································································

  internal func updateRenameComponentValidationButton () {
    if self.mComponentNewPrefix == "" {
      self.mRenameComponentValidationButton?.isEnabled = false
      self.mRenameComponentValidationButton?.title = "Rename"
    }else{
      self.mRenameComponentValidationButton?.isEnabled = true
      self.mRenameComponentValidationButton?.title = "Rename to \(self.mComponentNewPrefix):\(self.mComponentNewIndex)"
    }
  }

  //····················································································································

  private func getComponentNamePrefixes () -> Set <String> {
    var prefixSet = Set <String> ()
    for component in self.rootObject.mComponents {
      prefixSet.insert (component.mNamePrefix)
    }
    return prefixSet
  }

  //····················································································································

  private func getComponentNameIndexes (forPrefix inPrefix : String) -> Set <Int> {
    var indexes = Set <Int> ()
    for component in self.rootObject.mComponents {
      if component.mNamePrefix == inPrefix {
        indexes.insert (component.mNameIndex)
      }
    }
    return indexes
  }

  //····················································································································

  private func populatePrefixComboBox (_ currentPrefixSet : Set <String>, _ currentNamePrefix : String) {
    self.mRenameComponentPrefixComboxBox?.removeAllItems ()
    let sortedArray = Array (currentPrefixSet).sorted ()
    self.mRenameComponentPrefixComboxBox?.addItems (withObjectValues: sortedArray)
    if let idx = sortedArray.firstIndex(of: currentNamePrefix) {
      self.mRenameComponentPrefixComboxBox?.selectItem (at: idx)
    }
  }

  //····················································································································

  private func populateIndexesPopupButton (_ inCurrentIndex : Int) {
    var sortedIndexArray = Array (self.getComponentNameIndexes (forPrefix: self.mComponentNewPrefix)).sorted ()
    if self.mComponentNewPrefix != self.mComponentCurrentPrefix {
      sortedIndexArray.append (sortedIndexArray.count + 1)
    }
    self.mRenameComponentIndexesPopUpButton?.removeAllItems ()
    for idx in sortedIndexArray {
      self.mRenameComponentIndexesPopUpButton?.addItem (withTitle: "\(idx)")
    }
    if let idx = sortedIndexArray.firstIndex (of: inCurrentIndex) {
      self.mRenameComponentIndexesPopUpButton?.selectItem (at: idx)
    }else{
      self.mRenameComponentIndexesPopUpButton?.selectItem (at: sortedIndexArray.count - 1)
      self.mComponentNewIndex = sortedIndexArray.count
    }
  }

  //····················································································································

  internal func renameComponentComboBoxAction () {
    if let newPrefix = self.mRenameComponentPrefixComboxBox?.stringValue {
      // Swift.print ("newPrefix '\(newPrefix)'")
      if newPrefix == "" {
        self.mRenameComponentErrorMessageTextField?.stringValue = "Empty Prefix"
        self.mComponentNewPrefix = ""
        self.updateRenameComponentValidationButton ()
      }else{
      // Check all characters are letters
        var allLetters = true
        for character : UnicodeScalar in newPrefix.unicodeArray {
          if (character >= "A") && (character <= "Z") {
          }else if (character >= "a") && (character <= "z") {
          }else{
            allLetters = false
          }
        }
      //---
        if allLetters {
          self.mRenameComponentErrorMessageTextField?.stringValue = ""
          self.mComponentNewPrefix = newPrefix
          let selectedIndex = (self.mRenameComponentIndexesPopUpButton?.indexOfSelectedItem ?? 0) + 1
          self.populateIndexesPopupButton (selectedIndex)
        }else{
          self.mRenameComponentErrorMessageTextField?.stringValue = "Prefix should contain only ASCII letters"
          self.mComponentNewPrefix = ""
        }
        self.updateRenameComponentValidationButton ()
      }
    }
  }

  //····················································································································

  @objc internal func renameComponentIndexPopUpButtonAction (_ inSender : NSObject?) {
    if let newIndex = self.mRenameComponentIndexesPopUpButton?.indexOfSelectedItem {
      self.mComponentNewIndex = newIndex + 1
      self.updateRenameComponentValidationButton ()
    }
  }

  //····················································································································

  internal func performRenameComponent () {
    if self.mComponentNewPrefix == self.mComponentCurrentPrefix {
      if self.mComponentNewIndex > self.mComponentCurrentIndex { // Perform a roll down
        self.renameComponentSamePrefixNewIndexRollDown ()
      }else if self.mComponentNewIndex < self.mComponentCurrentIndex { // Perform a roll down
        self.renameComponentSamePrefixNewIndexRollUp ()
      }
    }else{ // Prefix change
      self.translateForMakingRoom ()
      self.mSelectedComponentForRenaming?.mNameIndex = self.mComponentNewIndex
      self.mSelectedComponentForRenaming?.mNamePrefix = self.mComponentNewPrefix
      self.translateForFillingHole ()
    }
    self.mSelectedComponentForRenaming = nil
  }

  //····················································································································

  private func renameComponentSamePrefixNewIndexRollDown () {
    for component in self.rootObject.mComponents {
      if component.mNamePrefix == self.mComponentNewPrefix { // Same prefix
        if component.mNameIndex == self.mComponentCurrentIndex {
          component.mNameIndex = self.mComponentNewIndex
        }else if (component.mNameIndex > self.mComponentCurrentIndex) && (component.mNameIndex <= self.mComponentNewIndex){
          component.mNameIndex -= 1
        }
      }
    }
  }

  //····················································································································

  private func renameComponentSamePrefixNewIndexRollUp () {
    for component in self.rootObject.mComponents {
      if component.mNamePrefix == self.mComponentNewPrefix {
        if component.mNameIndex == self.mComponentCurrentIndex {
          component.mNameIndex = self.mComponentNewIndex
        }else if (component.mNameIndex >= self.mComponentNewIndex) && (component.mNameIndex < self.mComponentCurrentIndex){
          component.mNameIndex += 1
        }
      }
    }
  }

  //····················································································································

  private func translateForMakingRoom () {
    for component in self.rootObject.mComponents {
      if component.mNamePrefix == self.mComponentNewPrefix {
        if component.mNameIndex >= self.mComponentNewIndex {
          component.mNameIndex += 1
        }
      }
    }
  }

  //····················································································································

  private func translateForFillingHole () {
    for component in self.rootObject.mComponents {
      if component.mNamePrefix == self.mComponentCurrentPrefix {
        if component.mNameIndex > self.mComponentCurrentIndex {
          component.mNameIndex -= 1
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
