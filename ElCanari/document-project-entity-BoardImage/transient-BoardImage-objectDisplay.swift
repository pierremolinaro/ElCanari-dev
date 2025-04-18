//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_BoardImage_objectDisplay (
       _ self_mCenterX : Int,                       
       _ self_mCenterY : Int,                       
       _ self_boardImageCodeDescriptor : BoardImageDescriptor,
       _ self_mLayer : BoardQRCodeLayer,            
       _ self_mRotation : Int,                      
       _ self_mPixelSize : Int,                     
       _ self_BoardObject_displayFrontLegendForBoard : Bool,
       _ self_BoardObject_displayBackLegendForBoard : Bool,
       _ prefs_frontSideLegendColorForBoard : NSColor,
       _ prefs_backSideLegendColorForBoard : NSColor
) -> EBShape {
//--- START OF USER ZONE 2
        let foreColor : NSColor
        let display : Bool
        switch self_mLayer {
        case .legendFront :
          foreColor = prefs_frontSideLegendColorForBoard
          display = self_BoardObject_displayFrontLegendForBoard
        case .legendBack :
          foreColor = prefs_backSideLegendColorForBoard
          display = self_BoardObject_displayBackLegendForBoard
        }
        var shape = EBShape ()
        if display {
          let displayInfos = boardImage_displayInfos (
            centerX: self_mCenterX,
            centerY: self_mCenterY,
            self_boardImageCodeDescriptor,
            frontSide: self_mLayer == .legendFront,
            pixelSizeInCanariUnit: self_mPixelSize,
            rotation: self_mRotation
          )
        //--- Background
          shape.add (filled: [displayInfos.backgroundBP], nil) // Transparent
        //--- Image
          shape.add (filled: [displayInfos.imageBP], foreColor)
        }
      //---
        return shape
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
