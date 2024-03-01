//
//  extension-ProjectDocument-rename-component.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate final class RenameContext {

  //································································································

  let mComponentCurrentIndex : Int
  let mComponentCurrentPrefix : String
  var mComponentNewIndex : Int
  var mComponentNewPrefix : String
  let mComboBox = AutoLayoutComboBox (width: 80)
  let mIndexesPopUpButton = AutoLayoutBase_NSPopUpButton (pullsDown: false, size: .regular)
  let mErrorLabel = AutoLayoutStaticLabel (title: "", bold: true, size: .regular, alignment: .right).setRedTextColor ()
  let mOkButton : AutoLayoutSheetDefaultOkButton
  let mDocument : AutoLayoutProjectDocument

  //································································································

  init (component inComponent : ComponentInProject,
        document inDocument : AutoLayoutProjectDocument,
        panel inPanel : NSPanel) {
    self.mComponentCurrentIndex = inComponent.mNameIndex
    self.mComponentNewIndex = inComponent.mNameIndex
    self.mComponentCurrentPrefix = inComponent.mNamePrefix
    self.mComponentNewPrefix = inComponent.mNamePrefix
    self.mOkButton = AutoLayoutSheetDefaultOkButton (title: "Rename", size: .regular, sheet: inPanel)
    self.mDocument = inDocument
    noteObjectAllocation (self)
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }


  //································································································

  func populatePrefixComboBox (_ currentPrefixSet : Set <String>) { // , _ currentNamePrefix : String) {
    self.mComboBox.removeAllItems ()
    let sortedArray = Array (currentPrefixSet).sorted ()
    self.mComboBox.addItems (withObjectValues: sortedArray)
    if let idx = sortedArray.firstIndex(of: self.mComponentCurrentPrefix) { // currentNamePrefix) {
      self.mComboBox.selectItem (at: idx)
    }
  }

  //································································································

  func renameComponentComboBoxAction () {
    let newPrefix = self.mComboBox.stringValue
    // Swift.print ("newPrefix '\(newPrefix)'")
    if let lastCharacter = newPrefix.last {
      if !lastCharacter.isWholeNumber {
        self.mErrorLabel.stringValue = ""
        self.mComponentNewPrefix = newPrefix
        self.populateIndexesPopupButton ()
      }else{
        self.mErrorLabel.stringValue = "Prefix last character should not be a digit"
        self.mComponentNewPrefix = ""
      }
    }else{
      self.mErrorLabel.stringValue = "Empty Prefix"
      self.mComponentNewPrefix = ""
    }
    self.updateValidationButton ()
  }

  //································································································

  func updateValidationButton () {
    if self.mComponentNewPrefix.isEmpty {
      self.mOkButton.isEnabled = false
      self.mOkButton.title = "Rename"
    }else{
      self.mOkButton.isEnabled = true
      self.mOkButton.title = "Rename to \(self.mComponentNewPrefix)\(self.mComponentNewIndex)"
    }
  }

  //································································································

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

  //································································································

  @objc func renameComponentIndexPopUpButtonAction (_ _ : Any?) {
    let newIndex = self.mIndexesPopUpButton.indexOfSelectedItem
    self.mComponentNewIndex = newIndex + 1
    self.updateValidationButton ()
  }

  //································································································

//  func populatePrefixComboBox (_ currentPrefixSet : Set <String>, _ currentNamePrefix : String) {
//    self.mComboBox.removeAllItems ()
//    let sortedArray = Array (currentPrefixSet).sorted ()
//    self.mComboBox.addItems (withObjectValues: sortedArray)
//    if let idx = sortedArray.firstIndex(of: currentNamePrefix) {
//      self.mComboBox.selectItem (at: idx)
//    }
//    self.updateValidationButton ()
//  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //································································································

  func renameComponentDialog (_ inComponent : ComponentInProject) {
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
      _ = layoutView.appendView (AutoLayoutStaticLabel (title: "Renaming Component", bold: true, size: .regular, alignment: .center))
      _ = layoutView.appendFlexibleSpace ()
    //---
      let gridView = AutoLayoutGridView2 ()
      do{
        let left = AutoLayoutStaticLabel (title: "Current Component Name", bold: false, size: .regular, alignment: .right)
        let currentComponentName = renameContext.mComponentCurrentPrefix + "\(renameContext.mComponentCurrentIndex)"
        let right = AutoLayoutStaticLabel (title: currentComponentName, bold: true, size: .regular, alignment: .center)
        _ = gridView.addFirstBaseLineAligned (left: left, right: right)
      }
    //---
      do{
        let left = AutoLayoutStaticLabel (title: "New Prefix (only letters)", bold: false, size: .regular, alignment: .right)
        renameContext.populatePrefixComboBox (currentPrefixSet)
        renameContext.mComboBox.mTextDidChange = { [weak renameContext] (_ inOutlet : AutoLayoutComboBox) in renameContext?.renameComponentComboBoxAction () }
        _ = gridView.addFirstBaseLineAligned (left: left, right: renameContext.mComboBox)
      }
    //---
      _ = gridView.add (single: renameContext.mErrorLabel)
    //---
      do{
        let left = AutoLayoutStaticLabel (title: "New Index", bold: false, size: .regular, alignment: .right)
        renameContext.populateIndexesPopupButton ()
        renameContext.mIndexesPopUpButton.target = renameContext
        renameContext.mIndexesPopUpButton.action = #selector (RenameContext.renameComponentIndexPopUpButtonAction (_:))
        _ = gridView.addFirstBaseLineAligned (left: left, right: renameContext.mIndexesPopUpButton)
      }
      _ = layoutView.appendView (gridView)
      _ = layoutView.appendFlexibleSpace ()
    //---
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        _ = hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular))
        _ = hStack.appendFlexibleSpace ()
        _ = hStack.appendView (renameContext.mOkButton)
        _ = layoutView.appendView (hStack)
      }
    //---
      panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
      window.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop {
          self.performRenameComponent (component: inComponent, renameContext: renameContext)
        }
      }
    }
  }

  //································································································

  private func getComponentNamePrefixes () -> Set <String> {
    var prefixSet = Set <String> ()
    for component in self.rootObject.mComponents_property.propval.values {
      prefixSet.insert (component.mNamePrefix)
    }
    return prefixSet
  }

  //································································································

  fileprivate func getComponentNameIndexes (forPrefix inPrefix : String) -> Set <Int> {
    var indexes = Set <Int> ()
    for component in self.rootObject.mComponents_property.propval.values {
      if component.mNamePrefix == inPrefix {
        indexes.insert (component.mNameIndex)
      }
    }
    return indexes
  }

  //································································································

  fileprivate func performRenameComponent (component inComponent : ComponentInProject,
                                           renameContext inRenameContext : RenameContext) {
    for component in self.rootObject.mComponents_property.propval.values {
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
    self.performNormalizeComponentNames ()
  }

  //································································································

  func performNormalizeComponentNames () {
    var allComponents = [String : [ComponentInProject]] ()
    for component in self.rootObject.mComponents_property.propval.values {
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

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
