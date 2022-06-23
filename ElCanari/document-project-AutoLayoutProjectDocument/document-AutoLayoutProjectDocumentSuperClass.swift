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

  final let mSheetController = ProjectSheetController ()

  //····················································································································
  //  POP UP BUTTON CONTROLLERS FOR SELECTING NET CLASS
  //····················································································································

  final let mSelectedWireNetClassPopUpController = CanariPopUpButtonControllerForNetClassFromSelectedWires ()
  final let mSelectedLabelNetClassPopUpController = CanariPopUpButtonControllerForNetClassFromSelectedLabels ()

  //····················································································································
  //  WIRE CREATED BY AN OPTION CLICK
  //····················································································································

  final var mWireCreatedByOptionClick : WireInSchematic? = nil

  //····················································································································
  //  TRACK CREATED BY AN OPTION CLICK
  //····················································································································

  final var mTrackCreatedByOptionClick : BoardTrack? = nil

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
