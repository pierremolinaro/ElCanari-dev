//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {
  @objc func insulateSubnetFromCurrentNetForSelectedLabelAction (_ sender : NSObject?) {
//--- START OF USER ZONE 2
    let selectedLabels = self.schematicLabelSelectionController.selectedArray
    if selectedLabels.count == 1 {
      let label = selectedLabels [0]
      let point = label.mPoint!
      let newNet = self.rootObject.createNetWithAutomaticName ()
      point.mNet = newNet
      point.propagateNetToAccessiblePointsThroughtWires ()
      self.updateSchematicPointsAndNets ()
    }
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————