//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {
  @objc func duplicateSelectedComponentsAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
        var newComponents = [ComponentInProject] ()
        for selectedComponent in self.componentController.selectedArray_property.propval.values {
          if let newComponent = self.duplicate (component: selectedComponent) {
            newComponents.append (newComponent)
          }
        }
        self.componentController.setSelection (newComponents)
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
