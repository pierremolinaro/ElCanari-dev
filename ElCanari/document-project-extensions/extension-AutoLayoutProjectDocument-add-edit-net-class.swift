//
//  extension-ProjectDocument-add-net-class.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/04/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func netClassEditionPanel (with inNetClass : NetClassInProject,
                                         creation inCreation : Bool, // true -> creation, false -> edition
                                         callBack inCallBack : @escaping @Sendable () -> Void) {
    if let window = self.windowForSheet {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 400, height: 500),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: .large)
      let gridView = AutoLayoutVerticalStackView ()
    //---
      let panelTitle = inCreation ? "Create Net Class" : "Edit Net Class"
      _ = layoutView.appendView (AutoLayoutStaticLabel (title: panelTitle, bold: true, size: .regular, alignment: .center))
      _ = layoutView.appendFlexibleSpace ()
    //---
      let netClassNameTextField = AutoLayoutTextField (minWidth: 100, size: .regular).expandableWidth ()
      netClassNameTextField.stringValue = inNetClass.mNetClassName
      do{
        let left = AutoLayoutStaticLabel (title: "Net Class Name", bold: false, size: .regular, alignment: .right)
        _ = gridView.append (left: left, right: netClassNameTextField)
      }
    //---
      let netClassNameErrorLabel = AutoLayoutStaticLabel (title: "", bold: true, size: .regular, alignment: .center)
         .expandableWidth ().set (alignment: .right).setRedTextColor ()
      _ = gridView.appendView (netClassNameErrorLabel)
    //--- Color
      let netColor_property = EBStandAloneProperty_NSColor (inNetClass.mNetClassColor)
      let wireColorWell = AutoLayoutColorWell ().bind_color (netColor_property)
      do{
        let left = AutoLayoutStaticLabel (title: "Wire Color in Schematics", bold: false, size: .regular, alignment: .right)
        _ = gridView.append (left: left, right: AutoLayoutHorizontalStackView.viewFollowedByFlexibleSpace (wireColorWell))
      }
    //---  Width
      let width_property = EBStandAloneProperty_Int (inNetClass.mTrackWidth) // 20 mils
      let widthUnit_property = EBStandAloneProperty_Int (inNetClass.mTrackWidthUnit) // mils
      let widthFields = AutoLayoutCanariDimensionAndPopUp (size: .regular).bind_dimensionAndUnit (width_property, widthUnit_property)
      do{
        let left = AutoLayoutStaticLabel (title: "Track Width", bold: false, size: .regular, alignment: .right)
        _ = gridView.append (left: left, right: widthFields)
      }
    //--- Hole Diameter
      let viaHoleDiameter_property = EBStandAloneProperty_Int (inNetClass.mViaHoleDiameter)
      let viaHoleDiameterUnit_property = EBStandAloneProperty_Int (inNetClass.mViaHoleDiameterUnit)
      let holeDiameterFields = AutoLayoutCanariDimensionAndPopUp (size: .regular).bind_dimensionAndUnit (viaHoleDiameter_property, viaHoleDiameterUnit_property)
      do{
        let left = AutoLayoutStaticLabel (title: "Via Hole Diameter", bold: false, size: .regular, alignment: .right)
        _ = gridView.append (left: left, right: holeDiameterFields)
      }
    //--- Pad Diameter
      let viaPadDiameter_property = EBStandAloneProperty_Int (inNetClass.mViaPadDiameter)
      let viaPadDiameterUnit_property = EBStandAloneProperty_Int (inNetClass.mViaPadDiameterUnit)
      let padDiameterFields = AutoLayoutCanariDimensionAndPopUp (size: .regular).bind_dimensionAndUnit (viaPadDiameter_property, viaPadDiameterUnit_property)
      do{
        let left = AutoLayoutStaticLabel (title: "Via Pad Diameter", bold: false, size: .regular, alignment: .right)
        _ = gridView.append (left: left, right: padDiameterFields)
      }
      _ = layoutView.appendView (gridView)
    //---  Allow front track
      let allowFrontTrack_property = EBStandAloneProperty_Bool (inNetClass.mAllowTracksOnFrontSide)
      let allowFrontTrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Front Layer", size: .regular).bind_value (allowFrontTrack_property).expandableWidth ()
      _ = layoutView.appendView (allowFrontTrackCheckBox)
    //---  Allow Inner 1 Layer
      let allowInner1Layer_property = EBStandAloneProperty_Bool (inNetClass.mAllowTracksOnInner1Layer)
      let allowInner1TrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Inner 1 Layer", size: .regular).bind_value (allowInner1Layer_property).expandableWidth ()
      _ = layoutView.appendView (allowInner1TrackCheckBox)
    //---  Allow Inner 2 Layer
      let allowInner2Layer_property = EBStandAloneProperty_Bool (inNetClass.mAllowTracksOnInner2Layer)
      let allowInner2TrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Inner 2 Layer", size: .regular).bind_value (allowInner2Layer_property).expandableWidth ()
      _ = layoutView.appendView (allowInner2TrackCheckBox)
    //---  Allow Inner 3 Layer
      let allowInner3Layer_property = EBStandAloneProperty_Bool (inNetClass.mAllowTracksOnInner3Layer)
      let allowInner3TrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Inner 3 Layer", size: .regular).bind_value (allowInner3Layer_property).expandableWidth ()
      _ = layoutView.appendView (allowInner3TrackCheckBox)
    //---  Allow Inner 4 Layer
      let allowInner4Layer_property = EBStandAloneProperty_Bool (inNetClass.mAllowTracksOnInner4Layer)
      let allowInner4TrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Inner 4 Layer", size: .regular).bind_value (allowInner4Layer_property).expandableWidth ()
      _ = layoutView.appendView (allowInner4TrackCheckBox)
    //---  Allow Back track
      let allowBackTrack_property = EBStandAloneProperty_Bool (inNetClass.mAllowTracksOnBackSide)
      let allowBackTrackCheckBox = AutoLayoutCheckbox (title: "Allow Tracks on Back Layer", size: .regular).bind_value (allowBackTrack_property).expandableWidth ()
      _ = layoutView.appendView (allowBackTrackCheckBox)
    //---
      _ = layoutView.appendFlexibleSpace ()
      let okButtonTitle = inCreation ? "Add New Net" : "Commit Changes"
      let okButton = AutoLayoutSheetDefaultOkButton (title: okButtonTitle, size: .regular, sheet: panel)
      do{
        let hStack = AutoLayoutHorizontalStackView ()
          .appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular))
          .appendFlexibleSpace ()
          .appendView (okButton)
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
      panel.setContentView (AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
    //---  Dialog
      window.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        DispatchQueue.main.async {
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
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func performAddNetClass () {
    let temporaryClass = NetClassInProject (nil)
    self.netClassEditionPanel (with: temporaryClass, creation: true) {
      DispatchQueue.main.async {
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
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
        DispatchQueue.main.async {
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
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
