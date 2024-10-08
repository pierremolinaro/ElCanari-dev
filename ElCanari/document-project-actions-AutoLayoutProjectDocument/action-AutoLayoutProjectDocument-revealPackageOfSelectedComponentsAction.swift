//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {
  @objc func revealPackageOfSelectedComponentsAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
    var componentToSelect = [BoardObject] ()
    var r = NSRect.null
    for component in self.componentController.selectedArray.values {
      if let padRect = component.selectedPackagePadsRect () {
        componentToSelect.append (component)
        r = r.union (padRect)
      }
    }
    self.boardObjectsController.addToSelection (objects: componentToSelect)
//    NSSound.beep ()
    self.rootObject.mSelectedPageIndex = 6
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
