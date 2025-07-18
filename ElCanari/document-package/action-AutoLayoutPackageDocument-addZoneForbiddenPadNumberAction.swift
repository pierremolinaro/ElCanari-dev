//--- START OF USER ZONE 1

extension AutoLayoutPackageDocument : NSTextFieldDelegate {

  func proposedPadNumberDidChange (_ padNumberProperty : EBStandAloneProperty <Int>,
                                   _ errorMessage_property : EBStandAloneProperty <String>,
                                   _ okButton : AutoLayoutSheetDefaultOkButton) {
    let proposedValue = padNumberProperty.propval
    let selectedZone = self.mPackageZoneSelectionController.selectedArray [0]
  //--- Current forbidden pad numbers
    var currentForbiddenPadNumberSet = Set <Int> ()
    for f in selectedZone.forbiddenPadNumbers.values {
      currentForbiddenPadNumberSet.insert (f.padNumber)
    }
    if currentForbiddenPadNumberSet.contains (proposedValue) {
      errorMessage_property.setProp ("Duplicate Pad Number")
      okButton.isEnabled = false
    }else{
      errorMessage_property.setProp ("")
      okButton.isEnabled = true
    }
  }
}

//--- END OF USER ZONE 1
//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutPackageDocument {
  @objc func addZoneForbiddenPadNumberAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
    if self.mPackageZoneSelectionController.selectedArray.count == 1, let window = self.windowForSheet {
      let selectedZone = self.mPackageZoneSelectionController.selectedArray [0]
    //-------------------------- Current forbidden pad numbers
      var currentForbiddenPadNumberSet = Set <Int> ()
      for f in selectedZone.forbiddenPadNumbers.values {
        currentForbiddenPadNumberSet.insert (f.padNumber)
      }
   //-------------------------- Propose an initial value for new forbidden pad number
      var initialValue = 1
      while currentForbiddenPadNumberSet.contains (initialValue) {
        initialValue += 1
      }
    //-------------------------- Models
      let newFordiddenPadNumber_property = EBStandAloneProperty <Int> (initialValue)
      let errorMessage_property = EBStandAloneProperty <String> ("")
    //-------------------------- Build Panel
      let panel = NSPanel ()
      let okButton = AutoLayoutSheetDefaultOkButton (title: "Add", size: .small, sheet: panel)
      let intField = AutoLayoutIntField (minWidth: 48, size: .small)
        .bind_value (newFordiddenPadNumber_property, sendContinously: true)
        .set (min: 1)
   //-------------------------- Add Observer for new forbidden pad number
      let observer = EBObservablePropertyController (
        observedObjects: [newFordiddenPadNumber_property],
        callBack: { [weak self] in
          self?.proposedPadNumberDidChange (newFordiddenPadNumber_property, errorMessage_property, okButton)
        }
      )
    //---
      let mainVStack = AutoLayoutVerticalStackView ().set (margins: .large)
    //--- Title
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        _ = hStack.appendFlexibleSpace ()
        let label = AutoLayoutStaticLabel (title: "Add a forbidden Pad Number to '\(selectedZone.zoneName)' Zone", bold: true, size: .regular, alignment: .center)
        _ = hStack.appendView (label)
        _ = hStack.appendFlexibleSpace ()
        _ = mainVStack.appendView (hStack)
      }
    //--- Horizontal Stack, app image -- contents
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        _ = hStack.appendView (AutoLayoutApplicationImage ())
        let contentsVStack = AutoLayoutVerticalStackView () ;
        _ = hStack.appendView (contentsVStack)
        _ = mainVStack.appendView (hStack)
      //--- Forbidden Pad Number
        do {
          let hStack = AutoLayoutHorizontalStackView ()
          let label = AutoLayoutStaticLabel (title: "New Forbidden Pad Number:", bold: false, size: .regular, alignment: .center)
          _ = hStack.appendView (label)
          panel.initialFirstResponder = intField
          _ = hStack.appendView (intField)
          _ = contentsVStack.appendView (hStack)
        }
      //--- Error message
        do{
          let errorMessage = AutoLayoutLabel (bold: false, size: .regular)
            .bind_title (errorMessage_property)
            .setRedTextColor ()
          _ = contentsVStack.appendView (errorMessage)
        }
        _ = contentsVStack.appendFlexibleSpace()
      //--- Buttons
        do {
          let hStack = AutoLayoutHorizontalStackView ()
          _ = hStack.appendFlexibleSpace()
          let cancelButton = AutoLayoutSheetCancelButton (title: "Cancel", size: .regular)
          _ = hStack.appendView (cancelButton)
          _ = hStack.appendView (okButton)
          _ = contentsVStack.appendView (hStack)
        }
      }
      panel.setContentSize (mainVStack.fittingSize)
      panel.setContentView (mainVStack)
   //-------------------------- Dialog
      window.beginSheet (panel) { (_ inResponse : NSApplication.ModalResponse) in
        DispatchQueue.main.async {
          observer.unregister ()
  //        intField.autoLayoutCleanUp ()
          if inResponse == .stop {
            let newForbiddenPadNumber = newFordiddenPadNumber_property.propval
            let fpn = ForbiddenPadNumber (self.undoManager)
            fpn.padNumber = newForbiddenPadNumber
            selectedZone.forbiddenPadNumbers.append (fpn)
          //---- Adjust pad number
            var pads = [PackagePad] ()
            for candidatePad in self.rootObject.packagePads.values {
              if candidatePad.zone === selectedZone {
                pads.append (candidatePad)
              }
            }
            pads.sort { $0.padNumber < $1.padNumber }
            var forbiddenPadNumberSet = Set <Int> ()
            for forbiddenPadNumber in selectedZone.forbiddenPadNumbers.values {
              forbiddenPadNumberSet.insert (forbiddenPadNumber.padNumber)
            }
            var newPadNumber = 1
            for pad in pads {
              while forbiddenPadNumberSet.contains (newPadNumber) {
                newPadNumber += 1
              }
              pad.padNumber = newPadNumber
              newPadNumber += 1
            }
          }
        }
      }
    }
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
