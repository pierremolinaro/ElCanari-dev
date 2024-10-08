//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {
  @objc func renameLabelNetWithNewAutomaticNameAction (_ inSender : NSObject?) {
//--- START OF USER ZONE 2
     var netSet = EBReferenceSet <NetInProject> ()
     for label in self.schematicLabelSelectionController.selectedArray.values {
       if let net = label.mPoint?.mNet {
         netSet.insert (net)
       }
     }
     for net in netSet.values {
       net.mNetName = self.rootObject.findUniqueNetName ()
     }
    self.updateSchematicPointsAndNets ()
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
