//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {
  @objc func changeLayerConfigurationAction (_ sender : NSObject?) {
//--- START OF USER ZONE 2
    if let popupButton = sender as? NSPopUpButton,
       let newLayerConfiguration = LayerConfiguration (rawValue: popupButton.indexOfSelectedItem) {
    //--- Current layer configuration
       let currentLayerConfiguration = self.rootObject.mLayerConfiguration
    //---
       if newLayerConfiguration.rawValue >= currentLayerConfiguration.rawValue {
         self.rootObject.mLayerConfiguration = newLayerConfiguration
       }else{
         self.rootObject.mLayerConfiguration = newLayerConfiguration
         self.invalidateERC ()
       }
    }
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————