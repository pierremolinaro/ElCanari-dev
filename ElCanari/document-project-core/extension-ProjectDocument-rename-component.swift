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
    let selectedComponents = self.componentController.selectedArray_property.propval
    if selectedComponents.count == 1 {
      self.renameComponentDialog (selectedComponents [0])
    }
  }

  //····················································································································

  @objc @IBAction func renameComponentFromComponentSymbolAction (_ sender : NSObject?) {  // Targeted in IB
    let selectedObjects = self.schematicObjectsController.selectedArray_property.propval
    if selectedObjects.count == 1,
        let symbol = selectedObjects [0] as? ComponentSymbolInProject,
        let component = symbol.mComponent {
      self.renameComponentDialog (component)
    }
  }

  //····················································································································

  internal func renameComponentDialog (_ inComponent : ComponentInProject) {
    if let window = self.windowForSheet, let panel = self.mRenameComponentPanel {
      self.mSelectedComponentForRenaming = inComponent
      self.mComponentCurrentIndex = inComponent.mNameIndex
      self.mComponentCurrentPrefix = inComponent.mNamePrefix
      self.mComponentNewIndex = inComponent.mNameIndex
      self.mComponentNewPrefix = inComponent.mNamePrefix
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
    for component in self.rootObject.mComponents.values {
      prefixSet.insert (component.mNamePrefix)
    }
    return prefixSet
  }

  //····················································································································

  private func getComponentNameIndexes (forPrefix inPrefix : String) -> Set <Int> {
    var indexes = Set <Int> ()
    for component in self.rootObject.mComponents.values {
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
    for component in self.rootObject.mComponents.values {
      component.mNameIndex *= 2 ;
    }
    if let selectedComponentForRenaming = self.mSelectedComponentForRenaming {
      if selectedComponentForRenaming.mNamePrefix == self.mComponentNewPrefix {
        if selectedComponentForRenaming.mNameIndex < (self.mComponentNewIndex * 2) {
          selectedComponentForRenaming.mNameIndex = self.mComponentNewIndex * 2 + 1
        }else{
          selectedComponentForRenaming.mNameIndex = self.mComponentNewIndex * 2 - 1
        }
      }else{
        selectedComponentForRenaming.mNameIndex = self.mComponentNewIndex * 2 - 1
        selectedComponentForRenaming.mNamePrefix = self.mComponentNewPrefix
      }
      self.mSelectedComponentForRenaming = nil
    }
    self.performNormalizeComponentNames ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  func performNormalizeComponentNames () {
    var allComponents = [String : [ComponentInProject]] ()
    for component in self.rootObject.mComponents.values {
      let prefix = component.mNamePrefix
      allComponents [prefix] = allComponents [prefix, default: []] + [component]
    }
    for (_, components) in allComponents {
      let sortedComponents = components.sorted { $0.mNameIndex < $1.mNameIndex }
      var idx = 1
      for component in sortedComponents {
        component.mNameIndex = idx
        idx += 1
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
