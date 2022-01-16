//
//  extension-ProjectDocument-rename-component.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class RenameContext : EBSwiftBaseObject {

  //····················································································································

  let mComponentCurrentIndex : Int
  let mComponentCurrentPrefix : String
  var mComponentNewIndex : Int
  var mComponentNewPrefix : String
  let mComboBox = AutoLayoutComboBox (width: 80)
  let mIndexesPopUpButton = AutoLayoutBase_NSPopUpButton (pullsDown: false, size: .regular)
  let mErrorLabel = AutoLayoutStaticLabel (title: "", bold: true, size: .regular).setRedTextColor ().set (alignment: .right)
  let mOkButton : AutoLayoutSheetDefaultOkButton
  let mDocument : AutoLayoutProjectDocument

  //····················································································································

  init (component inComponent : ComponentInProject,
        document inDocument : AutoLayoutProjectDocument,
        panel inPanel : NSPanel) {
    self.mComponentCurrentIndex = inComponent.mNameIndex
    self.mComponentNewIndex = inComponent.mNameIndex
    self.mComponentCurrentPrefix = inComponent.mNamePrefix
    self.mComponentNewPrefix = inComponent.mNamePrefix
    self.mOkButton = AutoLayoutSheetDefaultOkButton (title: "Rename", size: .regular, sheet: inPanel, isInitialFirstResponder: true)
    self.mDocument = inDocument
    super.init ()
  }

  //····················································································································

  func populatePrefixComboBox (_ currentPrefixSet : Set <String>) { // , _ currentNamePrefix : String) {
    self.mComboBox.removeAllItems ()
    let sortedArray = Array (currentPrefixSet).sorted ()
    self.mComboBox.addItems (withObjectValues: sortedArray)
    if let idx = sortedArray.firstIndex(of: self.mComponentCurrentPrefix) { // currentNamePrefix) {
      self.mComboBox.selectItem (at: idx)
    }
  }

  //····················································································································

  func renameComponentComboBoxAction () {
    let newPrefix = self.mComboBox.stringValue
    // Swift.print ("newPrefix '\(newPrefix)'")
    if newPrefix.isEmpty {
      self.mErrorLabel.stringValue = "Empty Prefix"
      self.mComponentNewPrefix = ""
      self.updateValidationButton ()
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
        self.mErrorLabel.stringValue = ""
        self.mComponentNewPrefix = newPrefix
//        let selectedIndex = self.mIndexesPopUpButton.indexOfSelectedItem + 1
        self.populateIndexesPopupButton ()
      }else{
        self.mErrorLabel.stringValue = "Prefix should contain only ASCII letters"
        self.mComponentNewPrefix = ""
      }
      self.updateValidationButton ()
    }
  }

  //····················································································································

  func updateValidationButton () {
    if self.mComponentNewPrefix.isEmpty {
      self.mOkButton.isEnabled = false
      self.mOkButton.title = "Rename"
    }else{
      self.mOkButton.isEnabled = true
      self.mOkButton.title = "Rename to \(self.mComponentNewPrefix)\(self.mComponentNewIndex)"
    }
  }

  //····················································································································

  func populateIndexesPopupButton () {
    var sortedIndexArray = Array (self.mDocument.getComponentNameIndexes (forPrefix: self.mComponentNewPrefix)).sorted ()
    if self.mComponentNewPrefix != self.mComponentCurrentPrefix {
      sortedIndexArray.append (sortedIndexArray.count + 1)
    }
    self.mIndexesPopUpButton.removeAllItems ()
    for idx in sortedIndexArray {
      self.mIndexesPopUpButton.addItem (withTitle: "\(idx)")
    }
    if let idx = sortedIndexArray.firstIndex (of: self.mComponentNewIndex) {
      self.mIndexesPopUpButton.selectItem (at: idx)
    }else{
      self.mIndexesPopUpButton.selectItem (at: sortedIndexArray.count - 1)
      self.mComponentNewIndex = sortedIndexArray.count
    }
    self.updateValidationButton ()
  }

  //····················································································································

  @objc func renameComponentIndexPopUpButtonAction (_ inSender : NSObject?) {
    let newIndex = self.mIndexesPopUpButton.indexOfSelectedItem
    self.mComponentNewIndex = newIndex + 1
    self.updateValidationButton ()
  }

  //····················································································································

  func populatePrefixComboBox (_ currentPrefixSet : Set <String>, _ currentNamePrefix : String) {
    self.mComboBox.removeAllItems ()
    let sortedArray = Array (currentPrefixSet).sorted ()
    self.mComboBox.addItems (withObjectValues: sortedArray)
    if let idx = sortedArray.firstIndex(of: currentNamePrefix) {
      self.mComboBox.selectItem (at: idx)
    }
    self.updateValidationButton ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

//  @objc @IBAction func renameComponentFromComponentSymbolAction (_ sender : NSObject?) {  // Targeted in IB
//    let selectedObjects = self.schematicObjectsController.selectedArray_property.propval
//    if selectedObjects.count == 1,
//        let symbol = selectedObjects [0] as? ComponentSymbolInProject,
//        let component = symbol.mComponent {
//      self.renameComponentDialog (component)
//    }
//  }

  //····················································································································

  internal func renameComponentDialog (_ inComponent : ComponentInProject) {
    if let window = self.windowForSheet {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 450, height: 250),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let renameContext = RenameContext (component: inComponent, document: self, panel: panel)
      let currentPrefixSet = self.getComponentNamePrefixes ()
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
    //---
      layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Renaming Component", bold: true, size: .regular))
      layoutView.appendFlexibleSpace ()
    //---
      let gridView = AutoLayoutGridView2 ()
      do{
        let left = AutoLayoutStaticLabel (title: "Current Component Name", bold: false, size: .regular).set (alignment: .right)
        let currentComponentName = renameContext.mComponentCurrentPrefix + "\(renameContext.mComponentCurrentIndex)"
        let right = AutoLayoutStaticLabel (title: currentComponentName, bold: true, size: .regular)
        _ = gridView.addFirstBaseLineAligned (left: left, right: right)
      }
    //---
      do{
        let left = AutoLayoutStaticLabel (title: "New Prefix (only letters)", bold: false, size: .regular).set (alignment: .right)
//        self.mRenameComponentPrefixComboxBox = renameContext.mComboBox
        renameContext.populatePrefixComboBox (currentPrefixSet) //, self.mComponentCurrentPrefix)
        renameContext.mComboBox.mTextDidChange = { [weak renameContext] (_ inOutlet : AutoLayoutComboBox) in renameContext?.renameComponentComboBoxAction () }
//        renameContext.mComboBox.isContinuous = true
        _ = gridView.addFirstBaseLineAligned (left: left, right: renameContext.mComboBox)
      }
    //---
      _ = gridView.add (single: renameContext.mErrorLabel)
    //---
      do{
        let left = AutoLayoutStaticLabel (title: "New Index", bold: false, size: .regular).set (alignment: .right)
//        self.mRenameComponentIndexesPopUpButton = popup
        renameContext.populateIndexesPopupButton ()
        renameContext.mIndexesPopUpButton.target = renameContext
        renameContext.mIndexesPopUpButton.action = #selector (RenameContext.renameComponentIndexPopUpButtonAction (_:))
        _ = gridView.addFirstBaseLineAligned (left: left, right: renameContext.mIndexesPopUpButton)
      }
      layoutView.appendView (gridView)
      layoutView.appendFlexibleSpace ()
    //---
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular, sheet: panel, isInitialFirstResponder: false))
        hStack.appendFlexibleSpace ()
        hStack.appendView (renameContext.mOkButton)
//        self.mRenameComponentValidationButton = button
   //     renameContext.updateValidationButton ()
        layoutView.appendView (hStack)
      }
    //---
      panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
      window.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop {
          self.performRenameComponent (component: inComponent, renameContext: renameContext)
        }
//        self.mRenameComponentPrefixComboxBox = nil
//        self.mRenameComponentErrorMessageTextField = nil
//        self.mRenameComponentIndexesPopUpButton = nil
//        self.mRenameComponentValidationButton = nil
//        self.mSelectedComponentForRenaming = nil
      }
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

  fileprivate func getComponentNameIndexes (forPrefix inPrefix : String) -> Set <Int> {
    var indexes = Set <Int> ()
    for component in self.rootObject.mComponents.values {
      if component.mNamePrefix == inPrefix {
        indexes.insert (component.mNameIndex)
      }
    }
    return indexes
  }

  //····················································································································

  fileprivate func performRenameComponent (component inComponent : ComponentInProject,
                                           renameContext inRenameContext : RenameContext) {
    for component in self.rootObject.mComponents.values {
      component.mNameIndex *= 2 ;
    }
    if inComponent.mNamePrefix == inRenameContext.mComponentNewPrefix {
      if inComponent.mNameIndex < (inRenameContext.mComponentNewIndex * 2) {
        inComponent.mNameIndex = inRenameContext.mComponentNewIndex * 2 + 1
      }else{
        inComponent.mNameIndex = inRenameContext.mComponentNewIndex * 2 - 1
      }
    }else{
      inComponent.mNameIndex = inRenameContext.mComponentNewIndex * 2 - 1
      inComponent.mNamePrefix = inRenameContext.mComponentNewPrefix
    }
//    self.mSelectedComponentForRenaming = nil
    self.performNormalizeComponentNames ()
  }

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
