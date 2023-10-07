//
//  controller-popup.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariPopUpButtonControllerForNetClassFromSelectedWires
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariPopUpButtonControllerForNetClassFromSelectedWires : EBOutletEvent {

  //····················································································································
  // Models
  //····················································································································

  private var mArrayModel : ReadWriteArrayOf_NetClassInProject? = nil
  private var mSelection : SelectionController_AutoLayoutProjectDocument_wireInSchematicSelectionController? = nil
  private weak var mOutlet : NSPopUpButton? = nil

  //····················································································································
  //  INIT
  //····················································································································

  override init () {
    super.init ()
    self.mEventCallBack = { [weak self] in self?.modelDidChange () }
  }

  //····················································································································

  final func register (_ inArrayModel : ReadWriteArrayOf_NetClassInProject,
                       _ inSelection : SelectionController_AutoLayoutProjectDocument_wireInSchematicSelectionController,
                       popUpButton inPopUpButton : NSPopUpButton) {
    self.mArrayModel = inArrayModel
    inArrayModel.toMany_mNetClassName_StartsBeingObserved (by: self)
    self.mSelection = inSelection
    inSelection.selectedArray_property.toMany_netClassName_StartsBeingObserved (by: self)
    self.mOutlet = inPopUpButton
    self.modelDidChange ()
  }

  //····················································································································

  private func modelDidChange () {
    if let popup = self.mOutlet {
      popup.removeAllItems ()
      if let arrayModel = self.mArrayModel?.propval, let selectedArray = self.mSelection?.selectedArray {
        var selectedNetClasses = EBReferenceSet <NetClassInProject> ()
        for wire in selectedArray.values {
          if let netClass = wire.mP1?.mNet?.mNetClass {
            selectedNetClasses.insert (netClass)
          }
        }
        if selectedNetClasses.count == 1, let selectedNetClass = selectedNetClasses.first {
          for netClass in arrayModel.values {
            popup.addItem (withTitle: netClass.mNetClassName)
            popup.lastItem?.representedObject = netClass
            popup.lastItem?.target = self
            popup.lastItem?.action = #selector (Self.setNetClassAction (_:))
            if selectedNetClass === netClass {
              popup.select (popup.lastItem)
            }
          }
        }
      }
    }
  }

  //····················································································································

  @objc private func setNetClassAction (_ inSender : NSMenuItem) {
    if let netClass = inSender.representedObject as? NetClassInProject,
     let selectedArray = self.mSelection?.selectedArray {
      for wire in selectedArray.values {
        if let net = wire.mP1?.mNet {
          net.mNetClass = netClass
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
