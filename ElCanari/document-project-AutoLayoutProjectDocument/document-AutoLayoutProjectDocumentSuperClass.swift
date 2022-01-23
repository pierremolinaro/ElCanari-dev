//
//  AutoLayoutProjectDocumentSuperClass.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 22/01/2022.
//

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutProjectDocumentSuperClass : EBAutoLayoutManagedDocument {

  //····················································································································

  let mSheetController = ProjectSheetController ()

  //····················································································································
  //  POP UP BUTTON CONTROLLERS FOR SELECTING NET CLASS
  //····················································································································

  let mSelectedWireNetClassPopUpController = CanariPopUpButtonControllerForNetClassFromSelectedWires ()
  let mSelectedLabelNetClassPopUpController = CanariPopUpButtonControllerForNetClassFromSelectedLabels ()

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
