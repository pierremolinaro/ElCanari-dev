//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {
  @objc func renameComponentFromSelectedSymbolAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
    let selectedObjects = self.schematicObjectsController.selectedArray_property.propval
    if selectedObjects.count == 1,
        let symbol = selectedObjects [0] as? ComponentSymbolInProject,
        let component = symbol.mComponent {
      self.renameComponentDialog (component)
    }
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————