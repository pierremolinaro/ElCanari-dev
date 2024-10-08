//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_MergerRoot_layoutLayerWarningMessage (
       _ self_mArtwork_layerConfiguration : LayerConfiguration?,
       _ self_boardModels_layerConfiguration : [any BoardModel_layerConfiguration]
) -> String {
//--- START OF USER ZONE 2
        var layerSet = Set <LayerConfiguration> ()
        if let artworkLayerConfiguration = self_mArtwork_layerConfiguration {
          layerSet.insert (artworkLayerConfiguration)
        }
        for boardModel in self_boardModels_layerConfiguration {
          layerSet.insert (boardModel.layerConfiguration)
        }
        if layerSet.count < 2 {
          return ""
        }else{
          var s = ""
          for layer in layerSet {
            if !s.isEmpty {
              s += ", "
            }
            switch layer {
            case  .twoLayers : s += "2"
            case .fourLayers : s += "4"
            case  .sixLayers : s += "6"
            }
          }
          if self_mArtwork_layerConfiguration == nil {
            return "Warning, models have different layout layer configuration: \(s)"
          }else{
            return "Warning, models and artwork have different layout layer configuration: \(s)"
          }
        }
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
