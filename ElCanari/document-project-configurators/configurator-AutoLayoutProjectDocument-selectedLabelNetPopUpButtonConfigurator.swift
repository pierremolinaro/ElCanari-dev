//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {
  final func configure_selectedLabelNetPopUpButtonConfigurator (_ inOutlet : AutoLayoutPopUpButton) {
//--- START OF USER ZONE 2
         self.mSelectedLabelNetClassPopUpController.register (
           self.rootObject.mNetClasses_property,
           self.schematicLabelSelectionController,
           popUpButton: inOutlet
         )
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------