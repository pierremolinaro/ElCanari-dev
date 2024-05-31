//
//  extension-ArtworkFileGenerationParameters.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/05/2024.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension ArtworkFileGenerationParameters {

  //································································································

  var layerItems : ProductLayerSet {
    var items = ProductLayerSet ()
    if self.drawBoardLimits {
      items.insert (.boardLimits)
    }
    if self.drawInternalBoardLimits {
      items.insert (.internalBoardLimits)
    }
    if self.drawComponentNamesTopSide {
      items.insert (.frontSideComponentName)
    }
    if self.drawComponentNamesBottomSide {
      items.insert (.backSideComponentName)
    }
    if self.drawComponentValuesTopSide {
      items.insert (.frontSideComponentValue)
    }
    if self.drawComponentValuesBottomSide {
      items.insert (.backSideComponentValue)
    }
    if self.drawPackageLegendTopSide {
      items.insert ([.frontSidePackageLegend, .frontSideLegendLine])
    }
    if self.drawPackageLegendBottomSide {
      items.insert ([.backSidePackageLegend, .backSideLegendLine])
    }
    if self.drawPadsTopSide {
      items.insert (.frontSideComponentPad)
    }
    if self.drawPadsBottomSide {
      items.insert (.backSideComponentPad)
    }
    if self.drawTextsLayoutTopSide {
      items.insert (.frontSideLayoutText)
    }
    if self.drawTextsLayoutBottomSide {
      items.insert (.backSideLayoutText)
    }
    if self.drawTextsLegendBottomSide {
      items.insert (.backSideLegendText)
    }
    if self.drawTracksTopSide {
      items.insert (.frontSideTrack)
    }
    if self.drawTracksInner1Layer {
      items.insert (.inner1Track)
    }
    if self.drawTracksInner2Layer {
      items.insert (.inner2Track)
    }
    if self.drawTracksInner3Layer {
      items.insert (.inner3Track)
    }
    if self.drawTracksInner4Layer {
      items.insert (.inner4Track)
    }
    if self.drawTracksBottomSide {
      items.insert (.backSideTrack)
    }
    if self.drawTraversingPads {
      items.insert (.innerComponentPad)
    }
    if self.drawVias {
      items.insert (.viaPad)
    }
    return items
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
