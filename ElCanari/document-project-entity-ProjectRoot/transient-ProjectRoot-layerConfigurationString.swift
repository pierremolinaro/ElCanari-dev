//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_ProjectRoot_layerConfigurationString (
       _ self_mLayerConfiguration : LayerConfiguration
) -> String {
//--- START OF USER ZONE 2
         switch self_mLayerConfiguration {
         case .twoLayers :
           return "2 Layers"
         case .fourLayers :
           return "4 Layers"
         case .sixLayers :
           return "6 Layers"
         }
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————