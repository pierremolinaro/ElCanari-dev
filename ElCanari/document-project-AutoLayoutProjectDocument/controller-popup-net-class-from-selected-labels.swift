//
//  controller-popup-net-class-from-selected-labels.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/05/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   CanariPopUpButtonControllerForNetClassFromSelectedLabels
//--------------------------------------------------------------------------------------------------

final class CanariPopUpButtonControllerForNetClassFromSelectedLabels : EBOutletEvent {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Models
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mArrayModel : ReadWriteArrayOf_NetClassInProject? = nil
  private var mSelection : SelectionController_AutoLayoutProjectDocument_schematicLabelSelectionController? = nil
  private weak var mOutlet : NSPopUpButton? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
    super.init ()
    self.mEventCallBack = { [weak self] in self?.modelDidChange () }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func register (_ inArrayModel : ReadWriteArrayOf_NetClassInProject,
                       _ inSelection : SelectionController_AutoLayoutProjectDocument_schematicLabelSelectionController,
                       popUpButton inPopUpButton : NSPopUpButton) {
    self.mArrayModel = inArrayModel
    inArrayModel.toMany_mNetClassName_StartsBeingObserved (by: self)
    self.mSelection = inSelection
    inSelection.selectedArray_property.toMany_netClassName_StartsBeingObserved (by: self)
    self.mOutlet = inPopUpButton
    self.modelDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  MODEL BINDING
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func bind_model (_ inArrayModel : ReadWriteArrayOf_NetClassInProject,
//                         _ inSelection : SelectionController_AutoLayoutProjectDocument_schematicLabelSelectionController) {
//    self.mArrayModel = inArrayModel
//    inArrayModel.addEBObserverOf_mNetClassName (self)
//    self.mSelection = inSelection
//    inSelection.selectedArray_property.addEBObserverOf_netClassName (self)
//    self.modelDidChange ()
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_model () {
//    self.mArrayModel?.removeEBObserverOf_mNetClassName (self)
//    self.mArrayModel = nil
//    self.mSelection?.selectedArray_property.removeEBObserverOf_netClassName (self)
//    self.mSelection = nil
// }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  OUTLETS
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func attachPopUpButton (_ inPopUpButton : NSPopUpButton?) {
//    self.mOutlet = inPopUpButton
//    self.modelDidChange ()
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func modelDidChange () {
    if let popup = self.mOutlet {
      popup.removeAllItems ()
      if let arrayModel = self.mArrayModel?.propval, let selectedArray = self.mSelection?.selectedArray {
        var selectedNetClasses = EBReferenceSet <NetClassInProject> ()
        for label in selectedArray.values {
          if let netClass = label.mPoint?.mNet?.mNetClass {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func setNetClassAction (_ inSender : NSMenuItem) {
    if let netClass = inSender.representedObject as? NetClassInProject,
     let selectedArray = self.mSelection?.selectedArray {
      for label in selectedArray.values {
        if let net = label.mPoint?.mNet {
          net.mNetClass = netClass
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
