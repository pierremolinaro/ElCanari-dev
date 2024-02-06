//
//  extension-ProjectDocument-add-net-class.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  fileprivate func netClassEditionPanel (with inNetClass : NetClassInProject,
                                         creation inCreation : Bool, // true -> creation, false -> edition
                                         callBack inCallBack : @escaping () -> Void) {
    if let window = self.windowForSheet {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 500),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
      let gridView = AutoLayoutGridView2 ()
    //---
      let panelTitle = inCreation ? "Create Net Class" : "Edit Net Class"
      _ = layoutView.appendView (AutoLayoutStaticLabel (title: panelTitle, bold: true, size: .regular, alignment: .center))
      _ = layoutView.appendFlexibleSpace ()
    //---
      let netClassNameTextField = AutoLayoutTextField (minWidth: 100, size: .regular).expandableWidth ()
      netClassNameTextField.stringValue = inNetClass.mNetClassName
      do{
        let left = AutoLayoutStaticLabel (title: "Net Class", bold: false, size: .regular, alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: netClassNameTextField)
      }
    //---
      let netClassNameErrorLabel = AutoLayoutStaticLabel (title: "", bold: true, size: .regular, alignment: .center)
         .expandableWidth ().set (alignment: .right).setRedTextColor ()
      _ = gridView.add (single: netClassNameErrorLabel)
    //--- Color
      let netColor_property = EBStoredProperty_NSColor (defaultValue: inNetClass.mNetClassColor, undoManager: nil, key: nil)
      let wireColorWell = AutoLayoutColorWell ().bind_color (netColor_property)
      do{
        let left = AutoLayoutStaticLabel (title: "Wire Color in Schematics", bold: false, size: .regular, alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: AutoLayoutHorizontalStackView.viewFollowedByFlexibleSpace (wireColorWell))
      }
    //---  Width
      let width_property = EBStoredProperty_Int (defaultValue: inNetClass.mTrackWidth, undoManager: nil, key: nil) // 20 mils
      let widthUnit_property = EBStoredProperty_Int (defaultValue: inNetClass.mTrackWidthUnit, undoManager: nil, key: nil) // mils
      let widthFields = AutoLayoutCanariDimensionAndPopUp (size: .regular).bind_dimensionAndUnit (width_property, widthUnit_property)
      do{
        let left = AutoLayoutStaticLabel (title: "Track Width", bold: false, size: .regular, alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: widthFields)
      }
    //---  Allow front track
      let allowFrontTrack_property = EBStoredProperty_Bool (defaultValue: inNetClass.mAllowTracksOnFrontSide, undoManager: nil, key: nil)
      let allowFrontTrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Front Layer", size: .regular).bind_value (allowFrontTrack_property).expandableWidth ()
      _ = gridView.addFirstBaseLineAligned (left: AutoLayoutHorizontalStackView (), right: allowFrontTrackCheckBox)
    //---  Allow Inner 1 Layer
      let allowInner1Layer_property = EBStoredProperty_Bool (defaultValue: inNetClass.mAllowTracksOnInner1Layer, undoManager: nil, key: nil)
      let allowInner1TrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Inner 1 Layer", size: .regular).bind_value (allowInner1Layer_property).expandableWidth ()
      _ = gridView.addFirstBaseLineAligned (left: AutoLayoutHorizontalStackView (), right: allowInner1TrackCheckBox)
    //---  Allow Inner 2 Layer
      let allowInner2Layer_property = EBStoredProperty_Bool (defaultValue: inNetClass.mAllowTracksOnInner2Layer, undoManager: nil, key: nil)
      let allowInner2TrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Inner 2 Layer", size: .regular).bind_value (allowInner2Layer_property).expandableWidth ()
      _ = gridView.addFirstBaseLineAligned (left: AutoLayoutHorizontalStackView (), right: allowInner2TrackCheckBox)
    //---  Allow Inner 3 Layer
      let allowInner3Layer_property = EBStoredProperty_Bool (defaultValue: inNetClass.mAllowTracksOnInner3Layer, undoManager: nil, key: nil)
      let allowInner3TrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Inner 3 Layer", size: .regular).bind_value (allowInner3Layer_property).expandableWidth ()
      _ = gridView.addFirstBaseLineAligned (left: AutoLayoutHorizontalStackView (), right: allowInner3TrackCheckBox)
    //---  Allow Inner 4 Layer
      let allowInner4Layer_property = EBStoredProperty_Bool (defaultValue: inNetClass.mAllowTracksOnInner4Layer, undoManager: nil, key: nil)
      let allowInner4TrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Inner 4 Layer", size: .regular).bind_value (allowInner4Layer_property).expandableWidth ()
      _ = gridView.addFirstBaseLineAligned (left: AutoLayoutHorizontalStackView (), right: allowInner4TrackCheckBox)
    //---  Allow Back track
      let allowBackTrack_property = EBStoredProperty_Bool (defaultValue: inNetClass.mAllowTracksOnBackSide, undoManager: nil, key: nil)
      let allowBackTrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Back Layer", size: .regular).bind_value (allowBackTrack_property).expandableWidth ()
      _ = gridView.addFirstBaseLineAligned (left: AutoLayoutHorizontalStackView (), right: allowBackTrackCheckBox)
    //--- Hole Diameter
      let viaHoleDiameter_property = EBStoredProperty_Int (defaultValue: inNetClass.mViaHoleDiameter, undoManager: nil, key: nil)
      let viaHoleDiameterUnit_property = EBStoredProperty_Int (defaultValue: inNetClass.mViaHoleDiameterUnit, undoManager: nil, key: nil)
      let holeDiameterFields = AutoLayoutCanariDimensionAndPopUp (size: .regular).bind_dimensionAndUnit (viaHoleDiameter_property, viaHoleDiameterUnit_property)
      do{
        let left = AutoLayoutStaticLabel (title: "Via Hole Diameter", bold: false, size: .regular, alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: holeDiameterFields)
      }
    //--- Pad Diameter
      let viaPadDiameter_property = EBStoredProperty_Int (defaultValue: inNetClass.mViaPadDiameter, undoManager: nil, key: nil)
      let viaPadDiameterUnit_property = EBStoredProperty_Int (defaultValue: inNetClass.mViaPadDiameterUnit, undoManager: nil, key: nil)
      let padDiameterFields = AutoLayoutCanariDimensionAndPopUp (size: .regular).bind_dimensionAndUnit (viaPadDiameter_property, viaPadDiameterUnit_property)
      do{
        let left = AutoLayoutStaticLabel (title: "Via Pad Diameter", bold: false, size: .regular, alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: padDiameterFields)
      }
    //---
      _ = layoutView.appendView (gridView)
      _ = layoutView.appendFlexibleSpace ()
      let okButtonTitle = inCreation ? "Add New Net" : "Commit Changes"
      let okButton = AutoLayoutSheetDefaultOkButton (title: okButtonTitle, size: .regular, sheet: panel)
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        _ = hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular))
        _ = hStack.appendFlexibleSpace ()
        _ = hStack.appendView (okButton)
        _ = layoutView.appendView (hStack)
      }
    //---
      if inCreation {
        netClassNameTextField.mTextDidChange = { [weak netClassNameTextField] in
          if let newNetClassName = netClassNameTextField?.stringValue {
            okButton.isEnabled = newNetClassName != ""
            if newNetClassName.isEmpty {
              netClassNameErrorLabel.stringValue = "New Net Class name is empty."
            }else{
              var newNameIsUnique = true
              for netClass in self.rootObject.mNetClasses.values {
                if netClass.mNetClassName == newNetClassName {
                  newNameIsUnique = false
                }
              }
              okButton.isEnabled = newNameIsUnique
              netClassNameErrorLabel.stringValue = newNameIsUnique
                ? ""
                : "New Net Class name already exists."
            }
          }
        }
      }else{
        netClassNameTextField.mTextDidChange = { [weak netClassNameTextField] in
          let selectedNetClasses = self.netClassController.selectedArray
          if selectedNetClasses.count == 1, let newNetClassName = netClassNameTextField?.stringValue {
            let editedNetClass = selectedNetClasses [0]
            if newNetClassName.isEmpty {
             okButton.isEnabled = false
             netClassNameErrorLabel.stringValue = "Net Class name is empty."
            }else{
              var newNameIsUnique = true
              for netClass in self.rootObject.mNetClasses.values {
                if (netClass !== editedNetClass) && (netClass.mNetClassName == newNetClassName) {
                  newNameIsUnique = false
                }
              }
              okButton.isEnabled = newNameIsUnique
              netClassNameErrorLabel.stringValue = newNameIsUnique
                ? ""
                : "Net Class name already exists."
            }
          }
        }
      }
    //---
      panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
    //---  Dialog
      window.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        if inResponse == .stop {
          inNetClass.mNetClassName = netClassNameTextField.stringValue
          inNetClass.mNetClassColor = netColor_property.propval
          inNetClass.mTrackWidth = width_property.propval
          inNetClass.mTrackWidthUnit = widthUnit_property.propval
          inNetClass.mViaHoleDiameter = viaHoleDiameter_property.propval
          inNetClass.mViaHoleDiameterUnit = viaHoleDiameterUnit_property.propval
          inNetClass.mViaPadDiameter = viaPadDiameter_property.propval
          inNetClass.mViaPadDiameterUnit = viaPadDiameterUnit_property.propval
          inNetClass.mAllowTracksOnFrontSide = allowFrontTrack_property.propval
          inNetClass.mAllowTracksOnInner1Layer = allowInner1Layer_property.propval
          inNetClass.mAllowTracksOnInner2Layer = allowInner2Layer_property.propval
          inNetClass.mAllowTracksOnInner3Layer = allowInner3Layer_property.propval
          inNetClass.mAllowTracksOnInner4Layer = allowInner4Layer_property.propval
          inNetClass.mAllowTracksOnBackSide = allowBackTrack_property.propval
          inCallBack ()
        }
      }
    }
  }

  //····················································································································

  func performAddNetClass () {
    let temporaryClass = NetClassInProject (nil)
    self.netClassEditionPanel (with: temporaryClass, creation: true) {
      let newClass = NetClassInProject (self.undoManager)
      newClass.mNetClassName = temporaryClass.mNetClassName
      newClass.mNetClassColor = temporaryClass.mNetClassColor
      newClass.mTrackWidth = temporaryClass.mTrackWidth
      newClass.mTrackWidthUnit = temporaryClass.mTrackWidthUnit
      newClass.mViaHoleDiameter = temporaryClass.mViaHoleDiameter
      newClass.mViaHoleDiameterUnit = temporaryClass.mViaHoleDiameterUnit
      newClass.mViaPadDiameter = temporaryClass.mViaPadDiameter
      newClass.mViaPadDiameterUnit = temporaryClass.mViaPadDiameterUnit
      newClass.mAllowTracksOnFrontSide = temporaryClass.mAllowTracksOnFrontSide
      newClass.mAllowTracksOnInner1Layer = temporaryClass.mAllowTracksOnInner1Layer
      newClass.mAllowTracksOnInner2Layer = temporaryClass.mAllowTracksOnInner2Layer
      newClass.mAllowTracksOnInner3Layer = temporaryClass.mAllowTracksOnInner3Layer
      newClass.mAllowTracksOnInner4Layer = temporaryClass.mAllowTracksOnInner4Layer
      newClass.mAllowTracksOnBackSide = temporaryClass.mAllowTracksOnBackSide
      self.rootObject.mNetClasses.append (newClass)
      self.netClassController.setSelection ([newClass])
    }
  }
  
  //····················································································································

  func performEditNetClass () {
    let selectedNetClasses = self.netClassController.selectedArray
    if selectedNetClasses.count == 1 {
      let editedNetClass : NetClassInProject = selectedNetClasses [0]
      let temporaryClass = NetClassInProject (nil)
      temporaryClass.mNetClassName = editedNetClass.mNetClassName
      temporaryClass.mNetClassColor = editedNetClass.mNetClassColor
      temporaryClass.mTrackWidth = editedNetClass.mTrackWidth
      temporaryClass.mTrackWidthUnit = editedNetClass.mTrackWidthUnit
      temporaryClass.mViaHoleDiameter = editedNetClass.mViaHoleDiameter
      temporaryClass.mViaHoleDiameterUnit = editedNetClass.mViaHoleDiameterUnit
      temporaryClass.mViaPadDiameter = editedNetClass.mViaPadDiameter
      temporaryClass.mViaPadDiameterUnit = editedNetClass.mViaPadDiameterUnit
      temporaryClass.mAllowTracksOnFrontSide = editedNetClass.mAllowTracksOnFrontSide
      temporaryClass.mAllowTracksOnInner1Layer = editedNetClass.mAllowTracksOnInner1Layer
      temporaryClass.mAllowTracksOnInner2Layer = editedNetClass.mAllowTracksOnInner2Layer
      temporaryClass.mAllowTracksOnInner3Layer = editedNetClass.mAllowTracksOnInner3Layer
      temporaryClass.mAllowTracksOnInner4Layer = editedNetClass.mAllowTracksOnInner4Layer
      temporaryClass.mAllowTracksOnBackSide = editedNetClass.mAllowTracksOnBackSide
      self.netClassEditionPanel (with: temporaryClass, creation: false) {
        editedNetClass.mNetClassName = temporaryClass.mNetClassName
        editedNetClass.mNetClassColor = temporaryClass.mNetClassColor
        editedNetClass.mTrackWidth = temporaryClass.mTrackWidth
        editedNetClass.mTrackWidthUnit = temporaryClass.mTrackWidthUnit
        editedNetClass.mViaHoleDiameter = temporaryClass.mViaHoleDiameter
        editedNetClass.mViaHoleDiameterUnit = temporaryClass.mViaHoleDiameterUnit
        editedNetClass.mViaPadDiameter = temporaryClass.mViaPadDiameter
        editedNetClass.mViaPadDiameterUnit = temporaryClass.mViaPadDiameterUnit
        editedNetClass.mAllowTracksOnFrontSide = temporaryClass.mAllowTracksOnFrontSide
        editedNetClass.mAllowTracksOnInner1Layer = temporaryClass.mAllowTracksOnInner1Layer
        editedNetClass.mAllowTracksOnInner2Layer = temporaryClass.mAllowTracksOnInner2Layer
        editedNetClass.mAllowTracksOnInner3Layer = temporaryClass.mAllowTracksOnInner3Layer
        editedNetClass.mAllowTracksOnInner4Layer = temporaryClass.mAllowTracksOnInner4Layer
        editedNetClass.mAllowTracksOnBackSide = temporaryClass.mAllowTracksOnBackSide
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
